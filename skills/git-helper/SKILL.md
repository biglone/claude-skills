---
name: git-helper
description: Git 操作指导，包括 rebase、merge 冲突解决等。当用户遇到 Git 问题、需要 Git 操作指导时使用。
allowed-tools: Bash, Read
---

# Git 助手

## 常用命令

### 基础操作
```bash
# 初始化仓库
git init

# 克隆仓库
git clone <url>
git clone --depth 1 <url>  # 浅克隆，只获取最新提交

# 查看状态
git status
git status -s  # 简短格式

# 查看日志
git log --oneline -10  # 简短格式，最近10条
git log --graph --all  # 图形化显示所有分支
git log --author="name"  # 按作者过滤
git log --since="2024-01-01"  # 按日期过滤
```

### 分支操作
```bash
# 查看分支
git branch       # 本地分支
git branch -r    # 远程分支
git branch -a    # 所有分支

# 创建分支
git branch <name>
git checkout -b <name>  # 创建并切换
git switch -c <name>    # 新语法

# 切换分支
git checkout <branch>
git switch <branch>  # 新语法

# 删除分支
git branch -d <name>    # 删除已合并的分支
git branch -D <name>    # 强制删除
git push origin --delete <name>  # 删除远程分支

# 重命名分支
git branch -m <old> <new>
```

### 提交操作
```bash
# 添加文件
git add <file>
git add .        # 添加所有
git add -p       # 交互式添加

# 提交
git commit -m "message"
git commit -am "message"  # 添加已跟踪文件并提交
git commit --amend        # 修改最后一次提交

# 撤销
git reset HEAD <file>     # 取消暂存
git restore <file>        # 丢弃工作区更改（推荐）
git restore --staged <file>  # 取消暂存（新语法）
```

### 远程操作
```bash
# 查看远程
git remote -v

# 添加远程
git remote add origin <url>

# 拉取
git fetch origin
git pull origin main

# 推送
git push origin main
git push -u origin main  # 设置上游分支
git push --force-with-lease  # 安全的强制推送
```

## 合并与变基

### Merge（合并）
```bash
# 合并分支
git checkout main
git merge feature

# 合并策略
git merge --no-ff feature  # 总是创建合并提交
git merge --squash feature  # 压缩为单个提交
```

### Rebase（变基）
```bash
# 变基到 main
git checkout feature
git rebase main

# 交互式变基（修改历史）
git rebase -i HEAD~3  # 修改最近3个提交

# 变基选项
# pick   - 保留提交
# reword - 修改提交信息
# edit   - 修改提交内容
# squash - 合并到前一个提交
# fixup  - 合并但丢弃提交信息
# drop   - 删除提交
```

## 冲突解决

### 解决流程
```bash
# 1. 查看冲突文件
git status

# 2. 编辑冲突文件，解决冲突标记
<<<<<<< HEAD
当前分支的内容
=======
合并分支的内容
>>>>>>> feature

# 3. 标记为已解决
git add <resolved-file>

# 4. 继续操作
git merge --continue  # 或
git rebase --continue

# 放弃操作
git merge --abort
git rebase --abort
```

### 使用工具
```bash
# 配置合并工具
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'

# 使用合并工具
git mergetool
```

## 撤销与回退

### 撤销提交
```bash
# 撤销最后一次提交（保留更改）
git reset --soft HEAD~1

# 撤销最后一次提交（保留工作区内容，不保留暂存）
git reset --mixed HEAD~1

# 创建新提交来撤销（推荐用于已推送的提交）
git revert <commit-hash>
git revert HEAD  # 撤销最后一次提交
```

### 恢复文件
```bash
# 恢复已删除的文件
git restore --source=HEAD -- <file>

# 从特定提交恢复
git restore --source=<commit-hash> -- <file>

# 恢复误删的分支
git reflog  # 查看操作历史
git checkout -b <branch> <commit-hash>
```

## 高级操作

### Stash（暂存）
```bash
# 暂存当前更改
git stash
git stash push -m "message"

# 查看暂存列表
git stash list

# 恢复暂存
git stash pop       # 恢复并删除
git stash apply     # 恢复但保留

# 删除暂存
git stash drop stash@{0}
git stash clear  # 删除所有
```

### Cherry-pick
```bash
# 选择特定提交应用到当前分支
git cherry-pick <commit-hash>
git cherry-pick <start>..<end>  # 范围

# 不自动提交
git cherry-pick -n <commit-hash>
```

### Bisect（二分查找）
```bash
# 找出引入 bug 的提交
git bisect start
git bisect bad              # 当前版本有问题
git bisect good <commit>    # 这个版本正常
# Git 会切换到中间提交，测试后标记
git bisect good  # 或 git bisect bad
# 重复直到找到问题提交
git bisect reset  # 完成后重置
```

## 常见问题

### 撤销已推送的提交
```bash
# 方式1：revert（推荐）
git revert <commit-hash>
git push

# 方式2：重写历史（高风险，仅团队确认后使用）
git rebase -i <commit-hash>^
git push --force-with-lease
```

### 修改已推送的提交信息
```bash
# 只能通过强制推送（危险）
git commit --amend -m "new message"
git push --force-with-lease
```

### 清理未跟踪文件
```bash
# 预览将删除的文件
git clean -n

# 删除未跟踪文件
git clean -f

# 删除未跟踪文件和目录
git clean -fd

# 删除忽略的文件
git clean -fX
```

## Git 配置

```bash
# 用户信息
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# 默认分支名
git config --global init.defaultBranch main

# 别名
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.st status
git config --global alias.lg "log --oneline --graph --all"
```
