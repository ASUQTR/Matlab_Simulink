# Creating the MATLAB project (recommended)

To create a MATLAB Project (.prj) for this repository (recommended for team workflows):

1. In MATLAB: `Home` → `New` → `Project` → `From Folder`.
2. Select the repository root (`C:\Programmation\ASUQTR\Matlab_Simulink`).
3. In Project Settings, add `projectStartup` to `Startup` so the paths are configured on open.
4. Commit the created `.prj` if you want to share the project settings. Note: some teams prefer not to commit user-specific project files.

Project benefits:
- Consistent startup path for all team members.
- Integrated shortcuts, tasks, and test runner.
- Easier CI integration using MATLAB Actions.
