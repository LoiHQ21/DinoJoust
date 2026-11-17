# Copy this into Codex as the first task

> You are working inside the Jurassic Joust: Crownfall GitHub repository. First read `AGENTS.md`, `README.md`, `docs/design/DECISIONS.md`, `docs/design/CAMERA_AND_UX.md`, `docs/design/COMBAT_AND_PHYSICS.md`, and `docs/production/TEST_PLAN.md`.
>
> The repository initially contains **documentation and concepts only**, not a playable engine project. Do not pretend code already exists. Recommend the smallest suitable engine/project scaffolding for true real-time 3D, Windows PC and mobile **landscape** targets. Unity URP is proposed but not yet approved; if the engine isn't explicitly selected in the current issue, make a concise choice/tradeoff recommendation, record the assumption, and proceed only with scope appropriate to that choice.
>
> Build **Milestone P1 only**: a reproducible graybox joust with guided opposing lanes; placeholder rider/mount 3D geometry; two control families (throttle and lance drag/commit); **rear three-quarter chase camera** while actively aiming; contact proxy hit grading (MISS / GLANCE / CLEAN), stability loss and deterministic dismount verdict; diagnostics and one repeatable play-mode test. Use one flat arena and two placeholder species; no hub, no cosmetics, no multiplayer, no full roguelite, no gore.
>
> Provide: file tree, local run steps, build steps as applicable, what you implemented, known limitations, acceptance test evidence classified as **verified / unverified / environment-blocked**, and the next single most valuable task. If engine or device access blocks validation, say so clearly and do not claim real phone performance.

## Next Codex task after graybox works

Add a single **contextual** species attack with a visible tell, a speed/contact window, and a rider-stability effect. It must require **no additional attack input**. Reuse the same collision/contact resolution as lance hits and maintain outcome determinism. Explain on-screen why the attack occurred and what counterplay exists.
