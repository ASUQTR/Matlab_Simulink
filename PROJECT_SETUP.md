# Creating the MATLAB project (recommended)

To create a MATLAB Project (.prj) for this repository (recommended for team workflows):

1. In MATLAB: `Home` → `New` → `Project` → `From Folder`.
2. Select the repository root (`C:\Programmation\ASUQTR\Matlab_Simulink`).
3. In Project Settings, add `projectStartup` to `Startup` so the paths are configured on open.
4. Commit the created `.prj` if you want to share the project settings. Note: some teams prefer not to commit user-specific project files.

## File roles to avoid confusion

- `projectStartup.m`: run at project start to configure paths, data folders and checks.
- `runWorkflow.m`: run for each new simulation.
- `startup.m`: fallback only, used when the repository is on the MATLAB path outside the project.
- `tools/create_matlab_project.m`: one-time helper to create the project, not part of the simulation loop.

Project benefits:
- Consistent startup path for all team members.
- Integrated shortcuts, tasks, and test runner.
- Easier CI integration using MATLAB Actions.
