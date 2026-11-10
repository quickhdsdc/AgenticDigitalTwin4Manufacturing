# Installation and updates

## Requirements

Use a 64-bit x86 computer with Docker Desktop in Linux-container mode, or Docker
Engine and Compose. The supplied image is Linux/amd64. Keep the extracted package
in a normal local folder with enough space for the image and your project files.

Download the complete deployment ZIP from Releases. GitHub's automatic source
archives contain this distribution page and launchers, not the prebuilt image.

## Configure your models

Copy `.env.example` to `.env`. For an OpenAI-compatible provider, fill
`REVIEW_GATEWAY_ENDPOINT`, `REVIEW_GATEWAY_API_KEY` and `REVIEW_GATEWAY_MODEL`.
Use **Models and usage** to select the connection for each stage. Azure connections
use the separate Azure variables in the template. Model tests send a small request
and may incur provider charges. Models need tool-calling support.

Scopus retrieval requires your Scopus API access. File imports and manual review
do not require a model or database API account. Keep `.env` private.

## Start and stop

Start Docker first. On Windows, double-click `start.cmd`; on Linux/macOS, run
`sh start.sh`. The first launch checks the image archive and loads it. Subsequent
launches reuse the matching image. Open http://127.0.0.1:8088.

Use `stop.cmd` or `sh stop.sh` to stop. Stopping preserves projects and the application
catalogue. Do not delete Docker volumes when stopping or updating the application.

## Updates and backups

Export complete project packages before updating. Stop the application and keep
your `.env`, `projects/` folder and Docker data volume. Extract the new release into
the installation folder, then start it. The launcher checks the release's image ID
instead of silently accepting an older image with the same name.

Project ZIP exports can contain research material. Inspect them before sharing.
Keep a private copy of your provider configuration separately.

## Desktop Zotero

The supplied application runs inside a container. Its localhost is different from
the host computer's localhost. Opening desktop Zotero alone does not give the
container access to its API or attachment files.

For the standard package, upload PDFs directly in **Full text and review**.
Zotero integration needs both a reachable local Zotero API endpoint and readable
mapped attachment paths. Keep the API local; do not expose it to the public internet.
Zotero collection writes also require Zotero's own authorization dialog.

## Troubleshooting

- **Docker unavailable:** start Docker Desktop and wait for the engine. Select Linux containers.
- **Image archive missing:** extract the complete deployment ZIP, not just the GitHub source archive.
- **Checksum mismatch:** download a fresh release; do not bypass verification.
- **Port occupied:** set `REVIEW_HOST_PORT` to an unused port in `.env` and start again.
- **PDF missing:** attach the original PDF. A saved summary cannot recreate it.
- **Model request fails:** check your endpoint, account access, selected model and provider limits.

The launcher binds the app to localhost. Public hosting and shared multi-user
accounts are not part of this distribution.
