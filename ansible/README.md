# Ansible

k3sクラスタのノード設定を管理する。

## 実行環境

**Windowsの場合はWSL上から実行すること。** WindowsネイティブのPython/AnsibleではSSH configの `~` 展開やProxyJumpが正しく動作しない。

## 実行方法

```bash
# 疎通確認
ansible all -m ping

# k3s設定の適用
ansible-playbook playbooks/k3s-config.yaml
```

## スコープ

現時点ではk3sノードの初期セットアップ（OSインストール、k3sインストール等）はAnsible管理外で手動で実施している。今後追加予定。

## Playbook一覧

| ファイル | 内容 |
|---|---|
| `playbooks/k3s-config.yaml` | control planeの `/etc/rancher/k3s/config.yaml` を管理（ServiceLB無効化など） |
| `playbooks/setup-master.yaml` | control planeのツール類をインストール（Helm等） |
