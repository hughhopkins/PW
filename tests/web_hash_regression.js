#!/usr/bin/env node

const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const html = fs.readFileSync(path.join(__dirname, '..', 'web', 'index.html'), 'utf8');
const scripts = Array.from(html.matchAll(/<script>([\s\S]*?)<\/script>/g), match => match[1]);
const appScript = scripts.find(script => script.includes('function hashV1'));
assert.ok(appScript, 'Could not find the PW hashing script in web/index.html');

function element() {
  return {
    value: '',
    innerText: '',
    className: '',
    style: {},
    addEventListener() {},
    classList: { add() {}, remove() {} }
  };
}

const elements = {
  srv: element(),
  pw: element(),
  password: element(),
  emojiCue: element(),
  copyButtons: element(),
  copyFeedback: element(),
  btnV1: element(),
  btnV2: element()
};

const sandbox = {
  document: {
    activeElement: null,
    addEventListener() {},
    getElementById(id) { return elements[id]; }
  },
  localStorage: {
    getItem() { return null; },
    setItem() {}
  },
  navigator: {},
  window: {},
  setTimeout() {}
};

vm.createContext(sandbox);
vm.runInContext(appScript, sandbox, { filename: 'web/index.html' });

function uppercaseEvenIndices(hex) {
  return Array.from(hex, (character, index) =>
    index % 2 === 0 ? character.toUpperCase() : character
  ).join('');
}

function canonicalV1(service, password) {
  const input = `${service}||${password}||`;
  const digest = crypto.createHash('sha1').update(input, 'utf8').digest('hex');
  return uppercaseEvenIndices(digest);
}

const cases = [
  ['facebook / hackference', 'facebook', 'hackference'],
  ['55-byte composite', 's', 'p'.repeat(50)],
  ['56-byte composite', 's', 'p'.repeat(51)],
  ['63-byte composite', 's', 'p'.repeat(58)],
  ['64-byte composite', 's', 'p'.repeat(59)],
  ['119-byte composite', 's', 'p'.repeat(114)],
  ['120-byte composite', 's', 'p'.repeat(115)],
  ['55-byte Unicode composite', 'é', 'p'.repeat(49)],
  ['56-byte Unicode composite', 'é', 'p'.repeat(50)],
  ['multi-block input', 'service', '🔐'.repeat(100)]
];

for (const [label, service, password] of cases) {
  assert.equal(
    sandbox.hashV1(service, password),
    canonicalV1(service, password),
    `${label} must match canonical/native SHA-1`
  );
}

elements.srv.value = 'Face Book';
elements.pw.value = 'hackference';
sandbox.setVersion(1);
assert.equal(
  elements.password.innerText,
  '762b679fA17b10D6Cc2d2194542d2235738b3e33',
  'UI service normalization must remain unchanged'
);

assert.equal(
  sandbox.hashV2('facebook', 'hackference'),
  'FfD.07fCb7c1869AcA60d9d31D3C58bEaFc82D01',
  'V2 must remain unchanged'
);

console.log(`Web hash regression tests passed (${cases.length + 2} checks).`);
