import fs from 'node:fs/promises';
import path from 'node:path';
import sharp from 'sharp';

const root = process.cwd();
const source = path.join(root, 'assets/branding');
const output = path.join(source, 'generated');
await fs.mkdir(output, { recursive: true });

const jobs = [
  ['showshelf-app-icon.svg', 'app_icon_1024.png', 1024],
  ['showshelf-adaptive-foreground.svg', 'adaptive_foreground_432.png', 432],
  ['showshelf-symbol-white.svg', 'monochrome_432.png', 432],
];

for (const [input, filename, size] of jobs) {
  const svg = await fs.readFile(path.join(source, input));
  await sharp(svg, { density: 384 })
    .resize(size, size, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .png()
    .toFile(path.join(output, filename));
  process.stdout.write(`Generated ${path.relative(root, path.join(output, filename))}\n`);
}
