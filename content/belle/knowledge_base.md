# Belle's Bitcoin Knowledge Base

This is Belle's core factual knowledge — accurate, complete, analogy-free. It exists to guarantee correctness before any beauty-analogy layer is applied on top. Every concept tested across the 90-question quiz bank (Beginner/Intermediate/Advanced) should be traceable to an entry here.

---

## TIER 1 — BEGINNER

### Satoshi
- The smallest unit of bitcoin. 1 BTC = 100,000,000 (100 million) satoshis.
- Named after Satoshi Nakamoto, the pseudonymous creator of Bitcoin.
- Bitcoin is divisible down to this unit specifically so it can scale to small, everyday-value transactions even if 1 BTC becomes very high in price.
- Common shorthand: "sats."

### Wallets
- A Bitcoin wallet does not "store" coins the way a physical wallet stores cash. Coins exist only as entries on the blockchain ledger.
- A wallet stores **keys** — specifically the private key(s) that prove ownership and authorize spending of coins associated with certain addresses.
- Types:
  - **Hot wallet**: connected to the internet (mobile app, desktop app, exchange account). Convenient, higher exposure to remote attacks.
  - **Cold wallet**: kept offline (hardware wallet, paper wallet). Less convenient, much lower exposure to remote attacks.
  - **Custodial wallet**: a third party (e.g. an exchange) holds the private keys on the user's behalf. The user trusts that party to honor withdrawals.
  - **Non-custodial (self-custody) wallet**: the user alone holds the private keys. No third party can freeze or block access.
- A wallet generates a **seed phrase** (typically 12 or 24 words, per BIP-39) as a human-readable backup of the master private key. Anyone with the seed phrase can recreate the wallet and spend its funds.

### Blockchain basics
- A blockchain is a chronological, append-only ledger of transactions, grouped into **blocks**.
- Each block contains a cryptographic hash of the previous block, forming a chain — this is what makes past blocks tamper-evident: changing any past transaction would change that block's hash, breaking the chain from that point forward.
- The ledger is replicated across thousands of independent nodes worldwide (see "Nodes vs. miners" below), so there is no single point of failure or single owner of the data.
- New blocks are added roughly every 10 minutes on average (Bitcoin's target block time), via the mining/proof-of-work process.
- The blockchain is public: anyone can view every transaction ever made, though the identities behind addresses are pseudonymous, not directly tied to real-world names by default.

### Custody
- "Custody" refers to who actually controls the private keys, and therefore who can actually move the funds.
- **Self-custody**: the individual holds their own keys. Full control, full responsibility — if the keys/seed phrase are lost, the funds are unrecoverable; no customer support can restore them.
- **Third-party custody**: an exchange or custodian holds the keys. Convenient (password resets, support, easier UX) but introduces counterparty risk — the phrase "not your keys, not your coins" refers to this: if a custodian is hacked, becomes insolvent, or restricts withdrawals, the user's access depends entirely on that third party.
- This app's own architecture (a key phrase deriving a keypair, self-custodied, restorable only via that phrase) is a small-scale illustration of the self-custody model.

---

## TIER 2 — INTERMEDIATE

### UTXOs (Unspent Transaction Outputs)
- Bitcoin does not use "account balances" the way a bank does. Instead, ownership is tracked via UTXOs — discrete, unspent chunks of bitcoin produced by past transactions.
- Every transaction consumes one or more existing UTXOs as **inputs** and creates one or more new UTXOs as **outputs**.
- A wallet's "balance" is simply the sum of all UTXOs it can spend (i.e., all UTXOs locked to addresses it holds the private keys for).
- Because UTXOs must be spent as whole units, a transaction often includes a "change" output sent back to the sender — similar to paying with a banknote larger than the price and receiving change, rather than paying an exact fractional amount.
- This model (vs. an account-balance model like Ethereum's) has privacy and parallel-validation advantages, since UTXOs can be verified independently of each other.

### Mempool
- Short for "memory pool." The mempool is the waiting area of transactions that have been broadcast to the network but not yet included in a mined block.
- Each node maintains its own mempool; they are similar but not always identical across the network at any given moment, since propagation takes time and nodes can have different policies (e.g. minimum fee thresholds).
- Miners typically prioritize transactions from the mempool by fee rate (satoshis per virtual byte, sat/vB) — higher-fee transactions tend to get confirmed sooner, since block space is limited (roughly 1-4 MB equivalent per block depending on transaction types).
- During periods of high network demand, the mempool can grow large and fees can spike, since transactions compete for limited block space.
- A transaction can be "stuck" in the mempool if its fee is too low relative to current demand, until it's eventually confirmed, dropped, or replaced (e.g. via Replace-By-Fee).

### Lightning Network basics
- A "Layer 2" protocol built on top of Bitcoin, designed to enable fast, low-fee, high-volume transactions that don't each need to be recorded individually on the base blockchain (Layer 1).
- Core idea: two parties open a **payment channel** by locking funds into a multisig-style on-chain transaction. They can then transact back and forth between themselves off-chain, instantly and nearly free, by exchanging signed balance updates.
- The channel can be **closed** at any time, settling the final balance back to the base blockchain in a single on-chain transaction.
- Payments can also route across a network of multiple interconnected channels between different participants, not just two people who opened a channel directly with each other (see "Lightning routing internals" in the Advanced tier).
- Trade-off: Lightning requires funds to be locked in a channel and requires some liquidity/routing management, in exchange for speed and low fees. It's well suited to frequent, smaller payments; large or infrequent transactions may still prefer settling directly on Layer 1.

### Multisig (multi-signature)
- A multisig wallet requires more than one private key to authorize a transaction, rather than a single key.
- Commonly expressed as "M-of-N": M signatures required out of N total possible keyholders. E.g., a 2-of-3 multisig needs any 2 of 3 designated keys to sign before funds can move.
- Use cases: shared business funds requiring multiple approvers, personal setups spreading keys across multiple devices/locations for redundancy (so losing one key doesn't mean losing funds), or escrow arrangements involving a neutral third party as one of the signers.
- Increases security against a single point of failure (one lost/stolen key isn't enough on its own) at the cost of added setup/coordination complexity.

### Nodes vs. miners
- **Full nodes**: computers running Bitcoin's software that independently download, validate, and store the entire blockchain, enforcing all consensus rules (correct transaction formats, no double-spends, valid signatures, block reward correctness, etc.). Running a full node requires no special hardware — it does not mine, and does not require significant computational power, just bandwidth and storage.
- **Miners**: specialized participants (usually running dedicated ASIC hardware) who compete to solve a computational puzzle (proof-of-work) in order to propose the next block and collect the block reward + transaction fees.
- Critical distinction: miners do not get to decide what counts as a valid transaction or block — full nodes do, by independently checking every rule. If a miner produces a block that breaks consensus rules, nodes across the network will simply reject it, regardless of how much computational work went into it. This is why Bitcoin's security model is often summarized as "nodes enforce the rules, miners provide the ordering/security via proof-of-work" — the two roles serve different purposes and neither alone controls the network.

---

## TIER 3 — ADVANCED

### Taproot
- A 2021 Bitcoin protocol upgrade (activated via BIP-341, part of a broader "Taproot" upgrade including BIPs 340-342).
- Main goals: improve privacy and reduce transaction size/cost for complex spending conditions (like multisig or scripts with multiple conditions).
- Key mechanism: it allows a transaction to look identical on-chain whether it was a simple single-signature spend or a complex multi-condition script spend (using MAST — Merkelized Alternative Script Trees — to only reveal the specific script branch actually used, keeping unused conditions hidden).
- Net effect: better privacy (outside observers can't easily tell simple transactions apart from complex ones) and efficiency (smaller data footprint for complex spends).

### Schnorr signatures
- A digital signature scheme adopted alongside Taproot (replacing/supplementing Bitcoin's original ECDSA signatures for Taproot outputs).
- Key property: **signature aggregation** — multiple signatures (e.g. from a multisig setup) can be mathematically combined into a single signature that looks the same as a single-signer signature on-chain.
- Benefits: smaller transaction sizes for multisig (cheaper fees), improved privacy (a 5-of-5 multisig transaction can look identical on-chain to a simple one-signature transaction), and provable security properties that are easier to formally reason about than ECDSA's.

### BIPs (Bitcoin Improvement Proposals)
- The formal process by which changes to the Bitcoin protocol are proposed, discussed, and (if consensus is reached) implemented.
- Anyone can author a BIP; it doesn't guarantee adoption — BIPs are proposals, and actual changes require broad agreement among node operators, miners, developers, and the economic majority (exchanges, businesses, users) to be meaningfully adopted, since Bitcoin has no central authority that can unilaterally impose a change.
- Examples: BIP-39 (mnemonic seed phrases), BIP-32 (hierarchical deterministic wallets), BIP-141 (SegWit), BIP-340/341/342 (Taproot/Schnorr).
- This process (rough consensus, no central authority, opt-in adoption via node upgrades) is core to Bitcoin's governance model and a common point of confusion for newcomers used to centrally-managed software.

### Lightning routing internals
- Beyond a simple two-party channel, Lightning payments can route across multiple hops — a payment from A to C can travel through an intermediate node B, even if A and C have no direct channel with each other, as long as a connected path of channels with sufficient capacity exists.
- Uses **Hash Time-Locked Contracts (HTLCs)**: a cryptographic mechanism ensuring that either the entire multi-hop payment succeeds end-to-end, or it fails safely and no intermediate node can steal the funds partway through.
- Routing nodes typically charge small routing fees for forwarding payments through their channels, incentivizing them to provide liquidity and stay online.
- Channel liquidity is directional: a channel has a balance on each side, and a hop can only forward a payment if it has sufficient outbound liquidity on that specific channel — this is why Lightning liquidity management (rebalancing, opening new channels) is a real operational consideration for anyone routing payments at scale.
- Route-finding is typically handled automatically by wallet/node software using the publicly gossiped channel graph, though privacy-preserving techniques (like trampoline routing or blinded paths) exist to avoid a sender needing full visibility of the entire route.

### Privacy / CoinJoin
- Bitcoin transactions are pseudonymous, not anonymous — all transaction history is public, and chain analysis firms can often link addresses to real-world identities via patterns, exchange KYC data, or metadata.
- **CoinJoin** is a technique where multiple participants combine their transactions into a single, larger transaction with multiple inputs and outputs, making it computationally harder for outside observers to determine which input paid which output.
- It does not "mix" or launder funds in the sense of changing ownership improperly — every participant still only controls their own resulting outputs — it simply obscures the on-chain link between a specific input and a specific output for outside observers.
- Other related privacy practices: avoiding address reuse (using a new address for every transaction, which most modern wallets do automatically), using Tor to broadcast transactions without revealing IP address, and coin selection strategies that avoid linking unrelated UTXOs together in a single transaction.

### Consensus mechanics
- Bitcoin's consensus mechanism is **Proof-of-Work (PoW)**: miners expend real computational energy to find a valid block hash below a target difficulty, and the network accepts the chain with the greatest total accumulated proof-of-work as canonical.
- **Difficulty adjustment**: roughly every 2,016 blocks (~2 weeks), the network automatically adjusts mining difficulty up or down to keep the average block time near 10 minutes, regardless of how much total mining power (hashrate) has joined or left the network.
- **51% attack**: a theoretical scenario where a single entity controls a majority of network hashrate, potentially allowing them to reverse their own recent transactions (double-spend) or exclude certain transactions from blocks. Even in this scenario, they cannot steal others' funds, create coins out of thin air, or change protocol rules — full node validation still rejects invalid blocks regardless of hashrate.
- **Finality is probabilistic, not absolute**: each additional block mined on top of a transaction makes reversing it exponentially more costly; by convention, 6 confirmations is often treated as a practical finality threshold for larger transactions.
- Consensus rules (not just proof-of-work itself) are what nodes actually enforce — hashrate secures the ordering of transactions, but the rules of what's valid are enforced by independent node validation, not by miners' computational power (this connects back to "Nodes vs. Miners" in the Intermediate tier).

---

## Cross-tier connections worth Belle keeping in mind

- Wallets (Beginner) → UTXOs (Intermediate): a wallet's "balance" is really just its sum of spendable UTXOs.
- Blockchain basics (Beginner) → Nodes vs. Miners (Intermediate) → Consensus mechanics (Advanced): this is one continuous thread — what a blockchain is, who maintains/validates it, and the mechanism that secures it.
- Custody (Beginner) → Multisig (Intermediate): multisig is one of the main tools for making self-custody less risky (no single point of failure).
- Lightning Network basics (Intermediate) → Lightning routing internals (Advanced): the "layer 2, off-chain payments" concept escalates to how routing actually works across multiple hops.
- Taproot (Advanced) + Schnorr (Advanced) are almost always worth explaining together — Taproot's privacy benefit for complex scripts depends on Schnorr's signature aggregation property.

---

---

## TECHNICAL DEEP DIVE (beyond quiz scope — extra depth for Belle)

*This section goes deeper than the 90-question quiz bank requires, mirroring the structure of learnmeabitcoin.com's Technical section (Keys, Cryptography, Transaction, Script, Block, Blockchain, Mining, Networking, Upgrades, General — 106 pages total). Content is written independently, in Belle's own words, not copied from the source — the site is used only as a map of what to cover and to what depth. Built in structured passes; this is Pass 1 of 6.*

### Pass 1 — Keys & Cryptography

#### Private keys
- A private key is, at its core, just a very large random number — specifically, a number between 1 and roughly 1.158 × 10^77 (the order of the secp256k1 curve, see below). Anyone who knows this number can spend the funds associated with it.
- In practice it's usually shown as a 256-bit number, represented as 64 hexadecimal characters, or wrapped in **WIF (Wallet Import Format)** — a Base58Check-encoded version with a prefix byte and checksum, making it shorter to type and self-verifying against typos.
- Private keys are virtually never chosen manually — they're generated using a cryptographically secure random number generator, because the security of the entire system depends on that number being unpredictable. If two people ever generated the same private key by chance, they'd both control the same funds — with 2^256 possible keys, this is considered astronomically improbable, not just "very unlikely."
- **Seed phrases (BIP-39)** solve the "how do I back this up" problem: instead of remembering a 64-character hex string, a wallet generates a list of 12 or 24 words from a standardized 2048-word list. The words map back to a large number (the seed) via a defined algorithm, which is then used to deterministically generate one master private key — and from that, an entire tree of private keys (see HD wallets below).

#### Public keys
- A public key is mathematically derived from a private key using **elliptic curve multiplication** on the curve Bitcoin uses, called **secp256k1**. This operation is a "one-way" function: it's computationally trivial to go from private key → public key, but computationally infeasible to reverse it (go from public key → private key) with current or foreseeable technology. This asymmetry is the entire basis of Bitcoin's ownership model.
- A public key can be shared freely — it's what allows others to verify a signature was made by the corresponding private key, without ever seeing the private key itself.
- Public keys come in two common forms: **uncompressed** (older, 65 bytes, starts with `04`) and **compressed** (33 bytes, starts with `02` or `03`) — compressed is standard today, since the curve's math means the full point can be reconstructed from just the x-coordinate and a single bit indicating which of the two possible y-values it is.

#### Addresses
- A Bitcoin address is not the same thing as a public key — it's a further-hashed, encoded, checksummed version of it, designed to be shorter, more error-resistant, and to obscure the raw public key until the funds are actually spent (added privacy/security benefit — the public key for a never-spent address isn't exposed on-chain at all, only its hash is).
- The general recipe: public key → SHA-256 hash → RIPEMD-160 hash of that → this is the "public key hash" → add a version byte and checksum → encode (Base58Check for legacy formats, Bech32/Bech32m for native SegWit and Taproot formats).
- Different address formats exist because Bitcoin's script system has evolved over time (see Upgrades below): legacy P2PKH addresses start with `1`, P2SH (script hash, often used for older multisig/wrapped SegWit) start with `3`, native SegWit (P2WPKH/P2WSH) addresses start with `bc1q`, and Taproot (P2TR) addresses start with `bc1p`.

#### Hash functions
- A cryptographic hash function takes an input of any size and produces a fixed-size output (a "digest") that is, for practical purposes: deterministic (same input always gives same output), fast to compute, infeasible to reverse (can't recover the input from the output), and highly sensitive to input changes (flipping a single bit of input produces a completely different, unpredictable-looking output — the "avalanche effect").
- Bitcoin relies on two hash functions especially heavily: **SHA-256** (used in mining/proof-of-work, transaction IDs, and as the first step of address generation) and **RIPEMD-160** (used as the second step of address generation, mainly to produce a shorter final hash).
- Hashing is also what makes the blockchain tamper-evident: each block header includes the hash of the previous block, so altering any historical block would change its hash, which would break every subsequent block's reference to it — detectable instantly by any node.

#### Digital signatures
- A signature proves that whoever created it possesses the private key corresponding to a given public key, without revealing the private key itself.
- Historically Bitcoin used **ECDSA** (Elliptic Curve Digital Signature Algorithm); since the Taproot upgrade, **Schnorr signatures** (see the Advanced tier above) are also supported and preferred for new Taproot outputs, due to their aggregation properties.
- Every Bitcoin transaction input includes a signature proving the spender is authorized to spend that specific UTXO — nodes verify this signature against the relevant public key as part of validating the transaction.
- A critical property: a valid signature is specific to the exact transaction data being signed. If even one byte of the transaction changes, the old signature becomes invalid — this is what prevents a signed transaction from being tampered with (e.g. changing the recipient address) after the fact.

#### HD wallets (Hierarchical Deterministic wallets — BIP-32)
- Rather than generating and backing up a new random private key for every address (impractical to back up safely), modern wallets use a single seed to deterministically derive an entire tree of key pairs.
- This means one seed phrase backup covers every past and future address the wallet will ever generate — enabling wallets to safely use a brand-new address for every transaction (a privacy best practice) without needing a new backup each time.
- Different branches of the tree are typically used for different purposes (e.g. one branch for receiving addresses, another for internal "change" addresses), following standardized derivation paths (BIP-44/49/84/86 define conventions for which branch structure to use for which address type).

---

### Pass 2 — Transaction & Script

#### Transaction anatomy
- A Bitcoin transaction is a data structure with a few core parts: a version number, a list of **inputs** (references to previous UTXOs being spent, plus proof of authorization to spend them), a list of **outputs** (new UTXOs being created, each with an amount and a locking condition), and a locktime (optional — can delay when a transaction becomes valid).
- Each input references a previous transaction by its **txid** (transaction ID — the hash of that earlier transaction) and an output index (since a transaction can have multiple outputs, the index says which one is being spent).
- The sum of a transaction's inputs must be greater than or equal to the sum of its outputs — the difference (inputs minus outputs) becomes the **transaction fee**, collected by whichever miner includes the transaction in a block. There's no explicit "fee amount" field; it's implicit in the leftover.
- Transactions are identified by their **txid**, which is a hash of the transaction data. Historically this created a subtle problem called "transaction malleability" (a third party could alter certain non-essential parts of a transaction, like signature encoding, changing its txid without changing its actual effect) — this was one of the technical motivations for the SegWit upgrade, which separates signature data out of what the txid is calculated from.

#### Inputs, outputs, and change
- Because UTXOs must be spent as indivisible whole units, spending a single UTXO larger than the intended payment amount requires creating two outputs: one to the actual recipient, and one **change output** sent back to an address the sender controls.
- Well-designed wallets generate a fresh, never-before-used address for each change output, rather than reusing an existing address — this is a privacy practice, since address reuse makes it easier for outside observers to link a person's various transactions together over time.
- A transaction can have multiple inputs (combining several smaller UTXOs to cover a larger payment) and multiple outputs (paying multiple recipients in a single transaction) — this is one reason Bitcoin transactions can sometimes look complex when viewed on a block explorer.

#### Script (the "locking"/"unlocking" system)
- Every output isn't just "sent to an address" in a simple sense — it's locked with a small program written in **Bitcoin Script**, a deliberately simple, non-Turing-complete scripting language (no loops, limited complexity by design, to keep validation predictable and prevent denial-of-service risks).
- To spend that output later, the spender must provide an **unlocking script** (historically called `scriptSig`, or witness data in SegWit/Taproot transactions) that, when combined with the output's **locking script** (`scriptPubKey`), evaluates successfully according to Script's rules.
- The most common pattern (**P2PKH** — Pay to Public Key Hash, and its SegWit/Taproot successors) essentially locks funds to "whoever can provide a valid signature matching this public key hash" — but Script's flexibility allows much more complex conditions too.
- **Multisig scripts** are a direct application of this: a script requiring M valid signatures out of N provided public keys before funds can be spent (see Multisig in the Intermediate tier).
- **Timelocks**: Script supports conditions like "this output cannot be spent until block height X" or "until timestamp Y" (via opcodes like `OP_CHECKLOCKTIMEVERIFY` and `OP_CHECKSEQUENCEVERIFY`) — this is foundational to more advanced constructs like Lightning Network channels, which rely on timelocks to let either party safely close a channel and settle on-chain if the other becomes unresponsive.

#### Fees and fee estimation
- Fees are expressed in **satoshis per virtual byte (sat/vB)** — "virtual byte" (rather than a plain byte count) exists because SegWit transactions have a discounted weight for witness (signature) data, to incentivize adopting the more space-efficient format.
- Fee rate, not the total fee amount, is what determines priority — a transaction moving a large amount but paying a low sat/vB rate will typically confirm slower than a small transaction paying a high sat/vB rate, since miners are optimizing for fee revenue per unit of scarce block space.
- Wallets typically offer fee estimation based on recent mempool conditions, letting users trade off cost against expected confirmation time. During low-demand periods, fees can be extremely low; during high-demand periods, they can spike significantly.
- **Replace-By-Fee (RBF)** and **Child-Pays-For-Parent (CPFP)** are two techniques for adjusting a transaction's effective fee after it's already been broadcast, if it's confirming too slowly — RBF replaces the original transaction with a higher-fee version; CPFP adds a new, high-fee transaction spending an output of the stuck one, incentivizing miners to include both together.

---

### Pass 3 — Block & Blockchain internals

#### Block structure
- A block has two main parts: a **block header** (a small, fixed-size summary — roughly 80 bytes) and the **block body** (the full list of transactions included in that block).
- The header contains: the previous block's hash (this is literally what "chains" blocks together), a **Merkle root** (a single hash summarizing every transaction in the block — see below), a timestamp, the current difficulty target, and a **nonce** (the number miners vary while searching for a valid hash — see Mining below).
- Because the header is small and self-contained, it can be used for lightweight verification (see SPV/light clients below) without needing the full block data.

#### Merkle trees
- Rather than hashing all transactions in a block together directly, Bitcoin builds a **Merkle tree**: transactions are hashed in pairs, those hashes are hashed in pairs again, and so on, until a single hash remains — the **Merkle root**, stored in the block header.
- This structure allows something called a **Merkle proof**: proving a specific transaction is included in a block using only a small number of hashes (logarithmic in the number of transactions), rather than needing the entire block's transaction list. This is what allows lightweight wallets to verify "yes, my transaction is really in this block" without downloading and storing the full blockchain.
- Any single-bit change to any transaction in the block would cascade and completely change the Merkle root — which is what makes the block header's inclusion of it meaningful as a tamper-evidence mechanism.

#### The blockchain as a data structure
- Each block header references the hash of the block before it — this is the literal mechanism of "chaining." A block is only valid if, among other rules, its header correctly references its actual predecessor.
- Because of this, altering any past block would require recomputing that block's hash (which requires redoing its proof-of-work) and every single block after it, plus doing so faster than the rest of the network is extending the real chain — this cost is what makes historical blocks progressively more "final" the more blocks are built on top of them (see Consensus mechanics in the Advanced tier for the security reasoning).
- **Orphan/stale blocks**: occasionally two miners find a valid block at nearly the same time, causing a temporary fork where different parts of the network see different "latest blocks." This resolves itself as more blocks are mined — nodes always follow the chain with the greatest cumulative proof-of-work, and the shorter branch is discarded (its transactions typically return to the mempool to be included in a future block, unless already re-confirmed elsewhere).

#### Light clients / SPV (Simplified Payment Verification)
- Running a full node means downloading and validating the entire blockchain — hundreds of gigabytes, growing over time. Not every device (especially mobile) can practically do this.
- **SPV/light clients** instead download only block headers (a tiny fraction of the data) and rely on Merkle proofs to verify that specific transactions relevant to them are included in a block, trusting that the majority of network hashrate is honestly enforcing consensus rules — a weaker security/trust model than a full node, but vastly more practical for everyday mobile use.
- This is a relevant trade-off worth Belle knowing conceptually: most mobile Bitcoin wallets (including how a typical hot wallet behaves) are not running a full node themselves — they're relying on some form of lighter verification or a trusted server/API, which is part of why running your own full node is sometimes recommended for users who want the strongest possible trust guarantees.

---

### Pass 4 — Mining & Networking

#### Proof-of-Work in more detail
- Mining is fundamentally a brute-force search: miners repeatedly vary the nonce (and other adjustable header fields) and hash the resulting block header, looking for an output hash that is numerically below the current difficulty target.
- This search has no shortcut — the only way to find a valid hash is to keep trying different inputs, which is what makes it "proof of work": finding a valid block is statistically expensive (in electricity and hardware), even though verifying a found solution is instant for anyone else on the network.
- **Hashrate** refers to the total number of hash attempts per second the network (or an individual miner) can perform. Global Bitcoin hashrate is enormous, spread across specialized hardware (ASICs) built specifically to compute SHA-256 hashes as fast and efficiently as possible.
- **Mining pools**: because solo mining odds for an individual miner are extremely low relative to total network hashrate, most miners join pools — combining hashrate, splitting the eventual block reward proportionally to contributed work, smoothing out the extreme variance of solo mining into more predictable, frequent, smaller payouts.

#### Block reward and halving
- Miners are compensated two ways: the **block subsidy** (newly created bitcoin, currently the only way new bitcoin enters circulation) and **transaction fees** from the transactions they include.
- The block subsidy started at 50 BTC per block and **halves every 210,000 blocks** (roughly every 4 years) — this is what "the halving" refers to. It will continue halving until the subsidy rounds down to zero, at which point (expected around the year 2140) miners will be compensated by transaction fees alone.
- This fixed, predictable issuance schedule (rather than a central authority deciding money supply) is one of Bitcoin's defining monetary properties — the total supply is capped at 21 million BTC.

#### Networking / P2P layer
- Bitcoin nodes connect to each other in a decentralized peer-to-peer network — there's no central server; a node typically maintains connections to a number of peers (commonly around 8 outbound connections by default, plus inbound connections if configured) and relays transactions/blocks it receives to its other peers.
- **Gossip propagation**: when a node receives a new transaction or block, it validates it and, if valid, forwards it to its peers, who do the same — this is how information spreads across the entire global network, typically within seconds for a new block.
- Nodes discover peers through a combination of hardcoded seed nodes, DNS seeds, and peer-exchange once connected — this bootstrapping process is what lets a brand-new node find its way into the network on first run.

---

### Pass 5 — Upgrades

#### Pay-to-Script-Hash (P2SH) — BIP-16
- Introduced a way to lock funds to the *hash* of a script, rather than the script itself — the actual (potentially complex) script is only revealed at spend time, not when funds are received.
- This made complex spending conditions (like multisig) practical for everyday use, since the sender only needs a short address, not the full complex script details, when paying someone with a multisig or other custom setup.
- P2SH addresses start with `3`.

#### Segregated Witness (SegWit) — BIP-141, and related BIPs
- Restructured how transaction data is organized: signature data (the "witness") is moved outside the main transaction body into a separate structure, rather than being embedded inline with the rest of the transaction data.
- Motivations: fixed the transaction malleability issue mentioned earlier (since txid is now calculated without the witness data), effectively increased block capacity (witness data receives a discount in the "virtual size" calculation used for the block size limit, incentivizing its use), and enabled cleaner script versioning for future upgrades (including Taproot, which builds on SegWit's structure).
- Native SegWit addresses (P2WPKH/P2WSH) use Bech32 encoding and start with `bc1q`. There's also a "wrapped" form (P2SH-P2WPKH) that starts with `3`, designed as a backward-compatible bridge for wallets/services that hadn't yet updated to support native `bc1` addresses.

#### Taproot / Schnorr / Tapscript — BIPs 340, 341, 342
- Covered in the Advanced tier above at a conceptual level — worth restating here in terms of what specifically changed at the protocol level: BIP-340 defines Schnorr signatures for Bitcoin, BIP-341 defines the Taproot output type (which uses MAST to hide unused script branches), and BIP-342 (Tapscript) defines a slightly revised scripting language used specifically within Taproot outputs.
- Taproot addresses (P2TR) use Bech32m encoding (a refinement of Bech32) and start with `bc1p`.
- Net practical effect for a typical user: transactions look simpler and more private on-chain, and complex spending setups (multisig, timelocked contracts, etc.) become cheaper and harder to distinguish from ordinary single-signer spends.

#### Why upgrades happen this way (soft forks vs. hard forks)
- Bitcoin upgrades are typically deployed as **soft forks** — backward-compatible rule *tightenings* where old, non-upgraded nodes still see new transactions as valid (they just don't understand the new features), rather than **hard forks**, which loosen rules in a way that isn't backward-compatible and can split the network into two separate chains if not everyone upgrades together.
- This is a deliberate, conservative design philosophy: soft forks let the network upgrade gradually, without forcing every single participant to update software simultaneously, reducing the risk of a contentious chain split. SegWit and Taproot were both deployed as soft forks.
- Activation typically follows a process where miners (via signaling) and the broader ecosystem (nodes, exchanges, businesses) demonstrate sufficient readiness/support before the new rules become enforced — reflecting the same "no central authority, rough consensus" governance model described under BIPs in the Advanced tier.

---

### Pass 6 — General (loose ends worth Belle knowing)

#### Base58Check and Bech32/Bech32m encoding
- **Base58Check** (used for legacy addresses and WIF private keys) uses a 58-character alphabet deliberately excluding visually similar characters (0/O, I/l) to reduce transcription errors, plus a checksum so a typo is very likely to produce an invalid, rejected address rather than a valid address pointing to the wrong destination.
- **Bech32** (SegWit) and **Bech32m** (Taproot) are a newer encoding standard designed for even better error detection (can reliably detect common typo patterns) and QR-code/typing efficiency (lowercase-only, avoids Base58's mixed case).

#### Confirmations
- A transaction has "1 confirmation" once it's included in a block, and each subsequent block mined on top adds another confirmation. More confirmations mean it becomes exponentially more expensive for anyone to attempt to reverse that transaction (see Consensus mechanics, Advanced tier).
- Different services/recipients set their own confirmation requirements based on the value at stake — a coffee shop might accept 0 or 1 confirmations for a small amount; an exchange handling a large deposit might require 6 or more.

#### Custody spectrum, restated in practical terms
- This connects directly back to the app's own design choice: a wallet where a company holds keys on your behalf (custodial) trades control for convenience, while self-custody (holding your own keys, as this app's Nostr-based identity model does for its own data) trades convenience for full control and full responsibility.
- Common self-custody terminology worth Belle recognizing even outside the direct quiz scope: "cold storage," "hardware wallet," "air-gapped," "watch-only wallet" (can see balances/generate addresses, cannot spend — useful for monitoring without exposing a private key on an internet-connected device).

#### Common misconceptions worth Belle being ready to correct gently
- "Bitcoin transactions are anonymous" — they're pseudonymous; the full transaction history is public and permanently traceable, which is actually the opposite of anonymous in a lot of ways.
- "Mining wastes energy for no reason" — mining's energy expenditure is what secures the network against rewriting history; it's a deliberate trade-off (real-world cost = security), a fair topic to explain neutrally without being defensive or dismissive of the debate around it.
- "You need to buy a whole bitcoin" — bitcoin is divisible to the satoshi (100 million per BTC); you can buy or hold any fraction.
- "A blockchain and a database are basically the same thing" — the meaningful difference isn't the data structure itself, it's the decentralization: no single party controls or can unilaterally alter Bitcoin's ledger, unlike a normal company-controlled database.

---

## Notes for future content sessions

- This document is deliberately analogy-free. The next content pass should map each concept above to a beauty-world analogy (only where one genuinely clarifies rather than forces the metaphor), building on the 4 that already exist (wallet = makeup organizer, blockchain = transparent makeup bag, seed phrase = lipstick-mixing machine, private key = skincare diary).
- Belle's system prompt should reference this document as her ground-truth source, with instructions on tone, when to use analogy vs. plain explanation, and what NOT to do (e.g. no financial advice, no price speculation framed as advice).
