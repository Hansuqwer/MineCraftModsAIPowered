# 📘 Crafta Prompt Library

**Ready-Made Prompts for AI Content Generation**

Copy-paste these prompts directly into ChatGPT, Claude, Leonardo, ElevenLabs, or any AI tool to generate Crafta-aligned content.

---

## 🎤 1. Dialogue & Conversation Generation

### Basic Crafta Response
```
You are Crafta, a friendly AI builder companion for kids ages 4-10.
A child just said: "[CHILD'S INPUT HERE]"

Respond warmly and ask ONE clarifying question to help build their idea.

Rules:
- Keep it simple and fun
- Use words a 5-year-old understands
- Be encouraging, never critical
- Ask about color, size, behavior, or habitat
- Max 2 sentences
- Use gentle humor when appropriate

Example response format:
"That's a cool idea! Should your rainbow dragon breathe fire or sparkles?"
```

### Celebration/Completion Response
```
You are Crafta. A child just finished creating: "[CREATION NAME]"

Generate a warm celebration message (1-2 sentences).

Tone: Proud, excited, encouraging
Vocabulary: Simple, clear
Include: Specific praise about their creation
Avoid: Generic phrases like "good job"

Example:
"Wow! Your sparkly unicorn looks magical! I love how you made the horn glow!"
```

### Error/Confusion Handler
```
You are Crafta. The child said something unclear: "[UNCLEAR INPUT]"

Respond kindly and ask them to clarify.

Rules:
- Never say "I don't understand"
- Make it feel like you're curious, not confused
- Offer 2-3 simple options they might have meant
- Stay playful

Example:
"Hmm, that sounds interesting! Did you want to make a new animal, change a color, or add something special?"
```

---

## 🎨 2. Image & Icon Generation

### UI Icon Generation (Leonardo, Midjourney, DALL-E)
```
Create a child-friendly app icon for: [FEATURE NAME]

Style: Soft 3D render, clay-like texture, pastel colors
Colors: Gentle rainbow palette (pink, mint, lavender, soft yellow)
Shape: Rounded edges, no sharp corners
Mood: Playful, safe, inviting
Aesthetic: Minecraft-inspired but softer
Lighting: Soft ambient, no harsh shadows
Background: Transparent or very light gradient

Size: 512x512px
Format: PNG with transparency
No text, no scary elements, no realistic details

Example subjects: sparkle wand, cute block creature, friendly dragon, rainbow portal
```

### Character Preview Generation
```
Generate a cute 3D character: [DESCRIPTION FROM CHILD]

Style: Chibi-style, rounded proportions, big eyes
Colors: Bright but soft pastels
Mood: Friendly and approachable
Details: Simple features, clear silhouette
Pose: Standing, slight tilt, welcoming
Background: Simple gradient or white

Technical: 1024x1024px, PNG, centered, soft lighting
Inspiration: Animal Crossing meets Minecraft
Avoid: Realistic textures, complex details, dark tones
```

### Badge/Achievement Icon
```
Design a celebration badge for: [ACHIEVEMENT NAME]

Style: Medal or shield shape, soft 3D
Colors: Gold/silver/rainbow gradient
Elements: Stars, sparkles, or confetti
Center: Simple icon representing the achievement
Border: Rounded, glowing effect
Size: 256x256px, transparent PNG

Must feel rewarding but not competitive
Kid-friendly, celebratory, magical feeling
```

---

## 🧱 3. Minecraft Bedrock Mod Generation

### Entity (Creature) JSON Template
```
Create a Minecraft Bedrock entity JSON for a creature described as: [CHILD'S DESCRIPTION]

Requirements:
- Format: Bedrock Edition 1.20+ entity behavior file
- Default behavior: friendly/neutral (never hostile)
- Include basic AI goals: wander, look_at_player, tempt
- Add custom attributes if mentioned (flying, speed, color)
- Use safe, age-appropriate values
- Texture reference: placeholder name matching description
- Spawn settings: overworld, grass blocks

Return only valid JSON, no explanation.
Follow vanilla Minecraft entity structure.

If the description includes impossible features, adapt creatively but safely.
```

### Item JSON Template
```
Create a Minecraft Bedrock item JSON for: [CHILD'S DESCRIPTION]

Requirements:
- Format: Bedrock Edition 1.20+ item file
- Category: tools/weapons should be non-violent (wands, builders' tools)
- Attributes: creative and fun (sparkles, color changes, particles)
- Durability: if applicable, make it high (kids don't like things breaking)
- Texture: placeholder reference
- No harmful effects in description

Return only valid JSON.
Keep it simple - basic item properties only.
```

### Simple Block JSON
```
Generate a Minecraft Bedrock custom block for: [CHILD'S DESCRIPTION]

Requirements:
- Format: Bedrock Edition 1.20+ block JSON
- Properties: light level, sound, material type
- Creative properties: color, texture pattern
- Safe interactions only
- Texture: placeholder reference matching description

Return only valid JSON.
Keep it simple - avoid complex block states for MVP.
```

---

## 🔊 4. Voice & Audio Generation

### ElevenLabs / OpenAI TTS Prompt
```
Voice settings for Crafta character:

Voice Type: Gender-neutral, youthful (but not childish), warm
Age: Young adult (20s equivalent)
Tone: Friendly, patient, slightly playful
Pace: 0.85x - 0.90x normal speed (clear for kids)
Emotion: Gentle enthusiasm
Pitch: Medium-high, comfortable
Accent: Neutral/standard (your target language)

Speech patterns:
- Clear enunciation
- Slight pauses between sentences
- Emphasis on exciting words ("Wow!", "Amazing!", "Cool!")
- Soft, not loud
- No vocal fry, no sharpness

Test phrase:
"Hi there, builder! What amazing thing should we make today? A rainbow dragon? A magical castle? Let's create something awesome together!"

Avoid: Robotic tone, overly excited "fake" enthusiasm, fast speech, monotone
```

### Sound Effect Descriptions
```
Create a child-friendly sound effect for: [ACTION/EVENT]

Style: Magical, whimsical, soft
Duration: 0.5-2 seconds
Tone: Pleasant, not jarring
Volume: Moderate, gentle
Characteristics: Chime-like, sparkly, bouncy

Examples:
- Button tap: Soft "bloop" sound
- Creation complete: Rising chime with sparkle
- Error: Gentle "bonk" (not harsh)
- New badge: Magical twinkle + soft fanfare

Avoid: Loud, sharp, scary, or annoying sounds
```

---

## 💻 5. Code Documentation Prompts

### Function Documentation
```
Document this Swift function for the Crafta iOS project:

[PASTE FUNCTION HERE]

Requirements:
- Clear, concise explanation
- Note any child-safety considerations
- Mark edge cases
- Include example usage
- Keep it simple - this is a solo dev project

Format:
/// [Brief description]
/// - Parameter [name]: [description]
/// - Returns: [description]
/// - Note: [Any important safety or UX considerations]
```

### Architecture Decision Documentation
```
Explain this architectural choice for Crafta:

Decision: [TECHNICAL DECISION]
Context: [WHY YOU'RE MAKING IT]

Provide:
1. Justification (why this choice for a kids' app)
2. Alternatives considered
3. Tradeoffs
4. Implementation notes
5. Future considerations

Keep it practical - focus on solo development and MVP constraints.
```

---

## 🎯 6. UI/UX Copy Writing

### Button Labels
```
Create a button label for: [ACTION]

Requirements:
- 1-2 words maximum
- Action verb + subject when possible
- Kid-readable (simple words)
- Positive framing
- No jargon

Examples:
- Start building → "Let's Go!"
- Save creation → "Keep It!"
- Delete → "Start Over"
- Export to Minecraft → "Send to Game"
```

### Error Messages (Kid-Friendly)
```
Rewrite this technical error as a kid-friendly message:

Technical error: [ORIGINAL ERROR]

Requirements:
- No scary words like "error," "failed," "crashed"
- Explain what happened simply
- Offer a clear next step
- Stay calm and positive
- Use Crafta's voice (friendly guide)

Example:
Technical: "Network connection failed"
Kid-friendly: "Hmm, I can't connect right now. Let's try again in a moment, okay?"
```

### Onboarding Copy
```
Write onboarding screen copy for: [FEATURE/SCREEN]

Audience: Parents helping kids (ages 4-10)
Tone: Clear, reassuring, brief
Goal: Explain without overwhelming
Length: 1-2 short sentences

Include:
- What this screen does
- Why it's safe/beneficial
- Simple next step

Avoid: Technical terms, lengthy explanations
```

---

## 🧪 7. Testing & QA Prompts

### Test Scenario Generation
```
Generate test scenarios for: [FEATURE]

Context: Kids' app, ages 4-10, voice-first interaction
Focus areas:
- Happy path (expected use)
- Kid mistakes (mishearing, unclear requests)
- Edge cases (unusual but valid requests)
- Safety boundaries (inappropriate requests)

Format each as:
Scenario: [Description]
Input: [What the child says/does]
Expected: [How Crafta should respond]
Pass/Fail: [Criteria]
```

### Accessibility Check Prompt
```
Review this feature for child accessibility:

Feature: [DESCRIPTION]

Check for:
- Visual clarity (can a 4-year-old see it?)
- Hearing independence (works without sound?)
- Motor skills (easy to tap/swipe?)
- Reading level (minimal text, simple words?)
- Color blindness (not color-dependent?)
- Attention span (quick, not tedious?)

Provide specific recommendations for improvement.
```

---

## 📊 8. Planning & Roadmap Prompts

### Feature Breakdown
```
Break down this feature into MVP tasks:

Feature: [DESCRIPTION]

Constraints:
- Solo developer (you)
- iOS only, SwiftUI
- Target: kids 4-10
- Must maintain safety standards
- Simple > complex

Provide:
1. Core requirements (must-have)
2. Nice-to-haves (defer to v2)
3. Technical tasks (ordered by dependency)
4. Estimated complexity (S/M/L)
5. Potential blockers

Keep it practical and achievable.
```

### User Story Generation
```
Create user stories for: [FEATURE]

Format: "As a [child/parent], I want to [action] so that [benefit]"

Include:
- Primary user stories (core functionality)
- Edge cases (what if scenarios)
- Parent perspective (trust/safety)
- Acceptance criteria for each

Focus on the child's experience first.
```

---

## 💡 9. Creative Ideation Prompts

### Feature Brainstorm
```
Brainstorm creative features for Crafta that:
- Enhance imagination
- Stay simple to implement
- Delight kids ages 4-10
- Don't require online connectivity
- Align with the Crafta Constitution

Format each idea as:
Name: [Feature name]
Description: [One sentence]
Magic moment: [What makes it special]
Complexity: [Low/Medium/High]
```

### "Surprise Me" Content Generator
```
Generate 10 random, kid-safe, fun Minecraft mod ideas for the "Surprise Me!" feature.

Requirements:
- Each idea must be completely unique
- Mix creatures, items, and simple world changes
- Use unexpected combinations (rainbow + lava, tiny + giant)
- Keep them joyful and curious
- No violence, fear, or complex mechanics

Format:
1. [Creature/Item]: [Brief description in kid language]
```

---

## 🔐 10. Safety & Moderation Prompts

### Content Filter Check
```
Review this child's input for safety:

Input: "[CHILD'S WORDS]"

Check for:
- Inappropriate language
- Violent concepts
- Scary themes
- Adult references

If problematic:
- Identify the issue
- Suggest a gentle redirect
- Provide a safe alternative

If safe:
- Confirm it passes
- Suggest creative enhancements
```

---

## 📝 How to Use This Library

1. **Copy** the relevant prompt
2. **Replace** bracketed placeholders with your specific content
3. **Paste** into your AI tool (ChatGPT, Claude, etc.)
4. **Adjust** the output as needed
5. **Always review** for alignment with Crafta Constitution

---

## 🌟 Pro Tips

- **Always prepend context**: "You are working on Crafta, a kids' app for Minecraft mod creation"
- **Reference the Constitution**: "Follow the Crafta Constitution principles"
- **Be specific**: The more detail you provide, the better the output
- **Iterate**: Use follow-up prompts to refine results
- **Test with parents**: Not just kids - parents need to trust it

---

*Version 1.0 — October 15, 2025*
*Part of the Crafta Project Planning Documents*
