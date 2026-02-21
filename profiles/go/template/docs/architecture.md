# Architecture（架构与边界）

## 中文（ZH）
### 目标
- 让代码结构与边界对 agent 可读，并可逐步被 CI/linters 强制（invariants）

### 不变式（Invariants）
- 依赖方向：tests/ 可以 import src/；src/ 不可 import tests/；scripts/ 不参与 import（由 `./scripts/arch-check` 自动检测）
- 边界校验：外部输入（HTTP request body、CLI args、env vars、file I/O）必须在入口处做 schema/type 校验
- 外部系统访问：所有外部 HTTP/DB/MQ 调用必须通过 src/clients/ 目录下的统一 client（集中重试/限流/观测）

### 验证方式
- 本地：./scripts/verify
- CI：.github/workflows/verify.yml

## English (EN)
### Goals
- Make structure & boundaries legible to agents, enforce via CI/linters (invariants)

### Invariants
- Dependency direction: tests/ may import src/; src/ must NOT import tests/; scripts/ does not participate in imports (enforced by `./scripts/arch-check`)
- Boundary validation: external inputs (HTTP request body, CLI args, env vars, file I/O) must be validated with schema/type at entry points
- External access: all external HTTP/DB/MQ calls must go through unified clients under src/clients/ (retries/rate-limit/observability centralized)

### Verification
- Local: ./scripts/verify
- CI: .github/workflows/verify.yml
