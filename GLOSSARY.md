# Glossary

This repo provides reusable mise tasks and prek hooks. Consumers pin them to a single release.

## Language

Task:
A reusable mise task that runs one workflow, such as linting or formatting a tool's files.
_Avoid_: Script, command

Hook:
A prek entry point that runs a Task on commits or pushes. Consumers reference a Hook by its id.
_Avoid_: Check, plugin

Manifest:
The published list of Hook definitions that consumers reference by id.
_Avoid_: Registry, catalogue

Local mirror:
This repository's own copy of the Manifest's Hooks, so it runs its Hooks from the working tree.
_Avoid_: Duplicate, fork

Consumer:
A repository that includes this repository's Tasks and Hooks at a pinned release.
_Avoid_: Client, downstream

Version:
A semver `X.Y.Z` value. Each released Version is also the git tag that records it.
_Avoid_: Release number, build number

Release cut:
The act of choosing a Version, tagging it, and pushing it.
_Avoid_: Publish, ship
