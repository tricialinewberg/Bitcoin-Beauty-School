import systemPrompt from "../../../content/belle/system_prompt.md";
import knowledgeBase from "../../../content/belle/knowledge_base.md";

// Belle's knowledge base is ~40KB (~10K tokens) today and will keep
// growing. That's still comfortably inside Claude's context window and
// cheap at this app's hobby scale, so sending the whole file as system
// context on every request is the right call *for now* — see the note in
// content/belle's README section. If it keeps growing, revisit this with
// per-topic retrieval instead of reaching for that complexity early.
//
// The two files are combined into one system string rather than passed as
// separate blocks, since belle_system_prompt.md already refers to the
// knowledge base by name and expects it alongside — splitting them
// wouldn't change anything the model sees, just how it's packaged.
export const belleSystemPrompt: string = systemPrompt;
export const belleKnowledgeBase: string = knowledgeBase;

export const combinedSystemPrompt = `${belleSystemPrompt}\n\n---\n\n# Belle's Knowledge Base (ground truth)\n\n${belleKnowledgeBase}`;
