// wrangler.toml declares a "Text" module rule for **/*.md, so these imports
// resolve to plain strings at build time — TypeScript just needs to be told
// that's the shape, since it has no built-in notion of a .md module.
declare module "*.md" {
  const content: string;
  export default content;
}
