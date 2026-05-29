# fix(devcontainer): Docker ソケット権限と compose-wp を修正

## Summary

- DevContainer 内で `compose-wp` 実行時に `permission denied` となる問題を修正
- `/var/run/docker.sock` の GID に合わせて `docker` グループを同期する `setup-docker-access.sh` を追加
- `postCreate` / `postStart` / `postAttach` で自動実行
- `compose-wp` に `sg docker` フォールバックと明確なエラーメッセージを追加

## 背景

DevContainer 内で次のエラーが発生していました。

```text
permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
compose-wp: wp-cli container is not running (project: wp).
```

`updateRemoteUserUID` 実行後、ホスト側 Docker ソケットの GID とコンテナ内 `docker` グループが一致しないことが原因です。

## 変更内容

| ファイル | 内容 |
| --- | --- |
| `.devcontainer/scripts/setup-docker-access.sh` | ソケット GID に `docker` グループを合わせ `node` を追加 |
| `.devcontainer/devcontainer.json` | ライフサイクルフックでセットアップスクリプトを実行 |
| `.devcontainer/Dockerfile` | `sudo` を追加（セットアップ用） |
| `.devcontainer/scripts/compose-wp.sh` | `sg docker` フォールバック |
| `docs/devcontainer.md` | トラブルシューティングを追記 |

## Test plan

- [ ] Dev Containers: Rebuild Container を実行
- [ ] `docker compose version` が DevContainer 内で成功すること
- [ ] `compose-wp plugin list` が成功すること
- [ ] 古い `node24-pnpm` イメージ削除後も Rebuild で起動すること
