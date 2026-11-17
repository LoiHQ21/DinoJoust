// Install gltf-validator outside the repo, then provide its node_modules via NODE_PATH.
// NODE_PATH=/tmp/crownfall-validation/node_modules node tools/validate_art_gltf.cjs
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const validator = require('gltf-validator');
const root = path.resolve(__dirname, '../assets/roster');

(async () => {
  const files = fs.readdirSync(path.join(root, 'glb')).filter(x => x.endsWith('.glb')).sort();
  if (files.length !== 6) throw new Error(`Expected six GLBs, found ${files.length}`);
  const results = [];
  for (const file of files) {
    const bytes = fs.readFileSync(path.join(root, 'glb', file));
    const report = await validator.validateBytes(new Uint8Array(bytes), { uri: file });
    results.push({ file, sha256: crypto.createHash('sha256').update(bytes).digest('hex'), ...report });
    console.log(`${file}: ${report.issues.numErrors} errors, ${report.issues.numWarnings} warnings`);
  }
  fs.writeFileSync(path.join(root, 'gltf_validation.json'), JSON.stringify(results, null, 2) + '\n');
  if (results.some(r => r.issues.numErrors)) process.exitCode = 1;
})().catch(error => { console.error(error); process.exitCode = 1; });
