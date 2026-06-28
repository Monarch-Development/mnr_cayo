/**
*   Copyright (c) 2026 Monarch Devs | All rights reserved.
* 
*   Monarch Auto-Versioning
*
*   Reads the conventional commits to calculate the new version and create a
*   new tag when the commit is a minor change (feat():) or a major change
*
*   Classification Rules:
*   - chore:                    ->  [ ](*.*.*)      ->  nothing happens
*   - fix: | perf:              ->  [+](*.*.^)      ->  bump
*   - feat:                     ->  [+](*.^.*)      ->  bump + tag + release
*   - !feat: | !fix: | !perf:   ->  [+](^.*.*)      ->  bump + tag + release
**/

import { execFileSync } from 'node:child_process';

const BUMP_RANK = { none: 0, patch: 1, minor: 2, major: 3 };
const TAGGING_TYPES = new Set(['feat']);
const COMMIT_HEADER_PATTERN = /^(!)?(\w+)(?:\([^)]*\))?:\s*(.+)/;
const SECTION_TITLES = { feat: 'Features', fix: 'Fixes', perf: 'Performance', other: 'Other' };
const SECTION_ORDER = ['feat', 'fix', 'perf', 'other'];

function parseArgs(argv) {
    const [fromRef, toRef, currentVersion] = argv;
    if (!fromRef || !toRef || !currentVersion) {
        process.stderr.write('Using versioning.mjs <fromRef> <toRef> <currentVersion>\n');
        process.exit(2);
    }
    if (!/^\d+\.\d+\.\d+$/.test(currentVersion)) {
        process.stderr.write(`Version not valid "${currentVersion}", expected X.Y.Z\n`);
        process.exit(2);
    }
    return { fromRef, toRef, currentVersion };
}

function loadCommitRange(fromRef, toRef) {
    const recordSeparator = '\u0001COMMIT\u0001';
    const fieldSeparator = '\x02';
    const format = `%H${fieldSeparator}%h${fieldSeparator}%s${fieldSeparator}%b${recordSeparator}`;

    let rawLog;
    try {
        rawLog = execFileSync(
          'git',
          ['log', `${fromRef}..${toRef}`, `--pretty=format:${format}`, '--no-merges'],
          { encoding: 'utf8', maxBuffer: 1024 * 1024 * 64 }
        );
    } catch (err) {
        process.stderr.write(`git log failed: ${err.message}\n`);
        process.exit(1);
    }

    return rawLog
        .split(recordSeparator)
        .map((entry) => entry.trim())
        .filter(Boolean)
        .map((entry) => {
          const [fullHash, shortHash, subject, body] = entry.split(fieldSeparator);
          return { fullHash, shortHash, subject: (subject || '').trim(), body: (body || '').trim() };
        })
        .reverse();
}

function classifyCommit(commit) {
    const match = COMMIT_HEADER_PATTERN.exec(commit.subject);
    if (!match) {
        return { type: 'other', breaking: false, description: commit.subject };
    }

    const [, breakingMarker, rawType, description] = match;
    const normalizedType = rawType.toLowerCase();
    const breaking = Boolean(breakingMarker);

    if (breaking) return { type: normalizedType, breaking, description, bumpLevel: 'major' };
    if (normalizedType === 'feat') return { type: normalizedType, breaking, description, bumpLevel: 'minor' };
    if (normalizedType === 'fix' || normalizedType === 'perf') {
        return { type: normalizedType, breaking, description, bumpLevel: 'patch' };
    }

    return { type: normalizedType, breaking, description, bumpLevel: 'none' };
}

function planRelease(classifiedCommits, currentVersion) {
    let bump = 'none';
    let tagWorthy = false;

    for (const commit of classifiedCommits) {
        if (BUMP_RANK[commit.bumpLevel] > BUMP_RANK[bump]) bump = commit.bumpLevel;
        if (commit.breaking || TAGGING_TYPES.has(commit.type)) tagWorthy = true;
    }

    return { bump, version: applyBump(currentVersion, bump), shouldTag: bump !== 'none' && tagWorthy };
}

function applyBump(version, bump) {
    if (bump === 'none') return version;

    const [major, minor, patch] = version.split('.').map(Number);
    if (bump === 'major') return `${major + 1}.0.0`;
    if (bump === 'minor') return `${major}.${minor + 1}.0`;
    return `${major}.${minor}.${patch + 1}`;
}

function buildChangelog(classifiedCommits) {
    const sections = { feat: [], fix: [], perf: [], other: [] };

    for (const commit of classifiedCommits) {
        const bucket = SECTION_TITLES[commit.type] ? commit.type : 'other';
        const prefix = commit.breaking ? '[BREAKING] ' : '';
        sections[bucket].push(`- ${prefix}${commit.description} (${commit.shortHash})`);
    }

    const renderedSections = SECTION_ORDER
        .filter((key) => sections[key].length > 0)
        .map((key) => `${SECTION_TITLES[key]}:\n${sections[key].join('\n')}`);

    return renderedSections.length > 0 ? renderedSections.join('\n\n') : 'No notable changes.';
}

function main() {
    const { fromRef, toRef, currentVersion } = parseArgs(process.argv.slice(2));

    const commits = loadCommitRange(fromRef, toRef);
    const classifiedCommits = commits.map((commit) => ({ ...commit, ...classifyCommit(commit) }));

    const { bump, version, shouldTag } = planRelease(classifiedCommits, currentVersion);
    const changelog = buildChangelog(classifiedCommits);

    process.stdout.write(JSON.stringify({ bump, version, shouldTag, changelog }) + '\n');
}

main();