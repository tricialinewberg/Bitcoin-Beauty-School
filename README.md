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
- Local-first key phrase authentication (no traditional login/signup)


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
