# ZuckMode

> *"I require that you perform adequate happiness at all times."*
> — Mark Zuckerberg (paraphrased, but you know he means it)

ZuckMode is a macOS menu bar app that dims your display proportionally to how little you're smiling. Stop smiling → screen fades to black. Smile like you're in a mandatory all-hands → full brightness returns.

Inspired by Mark Zuckerberg's reported workplace mandate that employees be relentlessly upbeat and "internally driven." ZuckMode externalizes that requirement directly onto your display hardware.

---

## How it works

1. Watches your face via the webcam — all on-device, no cloud, no data collection
2. Detects smiles using Apple's `CIDetector` (the same tech that puts dog ears on your selfies, now repurposed for surveillance-flavored productivity)
3. Overlays all connected displays with a black curtain, inversely proportional to your smile intensity
4. Smile score smoothly tracks your emotional compliance — rises fast when you smile, falls slowly when you lapse, so brief lapses in performative joy are forgiven

---

## Smile compliance table

| Menu bar | Smile score | Display state |
|----------|------------|---------------|
| 😊 | 60%+ | Clear — you are thriving |
| 😐 | 30–60% | Dimming — management has noticed |
| 😑 | <30% | Approaching darkness — a 1:1 is being scheduled |
| 😑 | 0% | Full blackout — you have been managed out |

---

## Requirements

- macOS 13+
- A Mac with a webcam
- A face
- A reason to smile (ZuckMode will not provide one)

---

## Build & run

```bash
git clone https://github.com/your-username/ZuckMode
cd ZuckMode
xcodegen generate
xcodebuild -scheme ZuckMode -configuration Debug \
  CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO \
  -derivedDataPath build
open build/Build/Products/Debug/ZuckMode.app
```

You'll be prompted for camera access. Grant it. There is no alternative.

---

## Privacy

Your camera feed never leaves your Mac. `CIDetector` runs fully on-device — no server calls, no face database, no engagement metrics. ZuckMode sees your face in real time and immediately forgets it.

Unlike some social media companies.

---

## FAQ

**Will this make me more productive?**
No. It will make you smile more, which may superficially resemble productivity.

**What if I work in a dark room?**
The detector may struggle. Your screen will also go dark. This is thematically appropriate.

**Can I disable it?**
Click the emoji in your menu bar → Quit ZuckMode. Freedom is one click away, which is more than can be said for some workplaces.

**Is this HIPAA compliant?**
It does not store, transmit, or process any biometric data. It does, however, judge you.

---

## License

MIT. Smile.
