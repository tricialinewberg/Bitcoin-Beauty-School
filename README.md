# Bitcoin Beauty School 💅₿

**Learn Bitcoin like beauty products — with gloss, grace & good vibes.**

A mobile app concept that teaches Bitcoin fundamentals through beauty analogies, designed for total beginners who find crypto intimidating — with a special focus on making the space more welcoming to women.


## The Idea

Bitcoin education is often gatekept by jargon. Terms like "private key," "seed phrase," or "cold wallet" can feel intimidating to newcomers — especially to an audience that rarely sees itself represented in the space.

**Bitcoin Beauty School** flips that. Every core Bitcoin concept is taught through a beauty-world analogy: a wallet becomes a makeup organizer, a blockchain becomes a transparent, tamper-proof makeup bag, a seed phrase becomes a custom lipstick-mixing machine that can recreate anything you've made. No dumbing down — just a different, more familiar language for the same real concepts.

At the center of the experience is **Belle**, an AI companion who teaches Bitcoin the way a best friend would: casual, encouraging, and always in on-brand analogies.


## Design Process

This project didn't start with screens — it started with the user.

1. **User journey mapping** — before any UI work, I mapped out the full journey of a Bitcoin beginner: where the confusion starts, what causes drop-off, and where an app like this could actually reduce friction instead of adding to it.
2. **Pain points research** — identified the specific moments that make Bitcoin apps feel unwelcoming (jargon-heavy onboarding, generic security warnings, no sense of personality or trust).
3. **Design system** — built a full visual identity in Figma: color palette, typography (Fredoka + Nunito Sans), a recurring "coin halo" motif, and a component library (buttons, inputs, cards) before touching a single screen.
4. **Screen design** — 18 screens designed end-to-end in Figma, covering onboarding, authentication, the AI chat experience, quizzes, and progress tracking.
5. **Development (in progress)** — now moving into building the app for real, in **Flutter**.

One deliberate design decision worth calling out: instead of a traditional email/password login, the app uses a **key phrase** system — a short, beauty-themed phrase generated on first use, inspired by how Bitcoin wallets handle seed phrases. It reflects Bitcoin's own privacy philosophy: no accounts, no personal data tied to your identity, just a phrase only you know.


## Tech Stack (planned)

- **Flutter** — cross-platform app development
- **Belle AI** — conversational AI integration for the in-app learning companion
- **Nostr** — the key phrase deterministically derives a Nostr keypair (same idea as a BIP-39 seed deriving Bitcoin keys), and that keypair is the account: no servers, no traditional login, progress and chat history sync as encrypted Nostr events instead of rows in a database

### A design note: why "Belle" isn't really a second party

Belle's chat history is stored using NIP-17 (Nostr's private direct message standard), which is built for two independent people who each keep their own private key secret. Belle isn't an independent person on the network — she's a persona inside the app with no server-side identity of her own. That's a real mismatch, and the easy fix (give the app one hardcoded "Belle" keypair, shared across every install) would be a privacy bug wearing a feature's clothes: that private key would ship inside the app binary on every device, so it wouldn't actually be private, and the "encrypted" conversation would be readable by anyone who bothered to extract it.

The fix: Belle's keypair is derived from the *same* key phrase as the user's own identity, just with a different derivation tag — the same one-way process, just two different labels going in. Nothing is shared across installs and nothing is hardcoded. The honest way to describe what this buys you: it's not a conversation with an independent Belle identity, it's the user's own client having a structured conversation with itself, wrapped in NIP-17's envelope for its metadata-privacy properties. Anyone who has the key phrase can derive both keys and read both sides — which is exactly the same person in every real scenario, since having the phrase already means having the whole account.

### A design note: why Belle's content lives in the repo but not in the app

[`content/belle/`](./content/belle) holds Belle's persona (`system_prompt.md`) and factual grounding (`knowledge_base.md`) — the instruction text and reference material an LLM needs to answer as Belle. Unlike [`content/quiz/`](./content/quiz), these files are **not** registered as Flutter assets and never ship inside the app binary.

The reason is what they're for: Belle's actual replies come from a real LLM API call, made by [`backend/belle-proxy`](./backend/belle-proxy) — a small Cloudflare Worker that holds the Anthropic API key server-side and includes this content as system/context for each request. The app itself never talks to the LLM directly and never needs this content on-device. Bundling it into the APK would serve no purpose (the client doesn't run the model) while needlessly exposing Belle's full prompt engineering and knowledge base to anyone who unpacks the app. Keeping it in the repo, out of the asset bundle, is what makes that split possible without restructuring anything.

This is also the one deliberate exception to this project's otherwise backend-free, self-custodied design (see the Nostr note above) — an LLM API key genuinely can't live on a device the way the rest of this app's data can. See [`backend/belle-proxy/README.md`](./backend/belle-proxy/README.md) for the full reasoning on platform choice, abuse protection, and setup. The Flutter app doesn't call this endpoint yet — that wiring is still a separate, not-yet-started step.

**Heads-up for later:** `knowledge_base.md` is already ~40KB (quiz-tier content plus all 6 planned "technical deep dive" passes). That's manageable as a single system-context block today, but it's worth watching — if it keeps growing, a future backend pass may need to send only the relevant section per conversation (e.g. by topic or quiz tier) rather than the whole file on every request, to stay comfortably inside the LLM's context window and keep prompt costs down. Not a problem yet, just flagging it before it becomes one.


## Design

Full design system and screens are available in Figma:
**[View on Figma →](https://www.figma.com/design/8s38gKBjlSFw2vvFAToxmW/bitcoin-beauty-school--c%C3%B3pia-?node-id=1-2&t=Yn9LVZyBMbgtI4KK-1)**

### Brand

<p align="left">
  <img src="design/brand/LOGO.png" width="200" alt="Bitcoin Beauty School logo" />
  <img src="design/brand/Belle avatar.png" width="200" alt="Belle, the AI companion" />
</p>

### Screens

A selection of the 18 screens designed for this project — from onboarding to the Belle AI chat, quizzes, and progress tracking.

<p align="left">
  <img src="design/screens/Onboarding 1.png" width="200" />
  <img src="design/screens/Onboarding 2.png" width="200" />
  <img src="design/screens/Onboarding 3.png" width="200" />
  <img src="design/screens/Home.png" width="200" />
  <img src="design/screens/Side Menu.png" width="200" />
  <img src="design/screens/Belle.png" width="200" />
  <img src="design/screens/Belle Chat.png" width="200" />
  <img src="design/screens/Quiz.png" width="200" />
</p>

*See the [`/design`](./design) folder for the complete set.*


## Status

- [x] User journey mapping & pain point research
- [x] Design system (Figma)
- [x] 18 screens designed
- [ ] Flutter development
- [ ] Belle AI integration
- [ ] Beta release


## About

Designed and built by **Tricia Linewberg** — UX/UI & Product Designer.

[LinkedIn](https://www.linkedin.com/in/tricia-linewberg/)
