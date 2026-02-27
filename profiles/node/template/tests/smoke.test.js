// 冒烟测试：验证项目基本可用。新建项目后请替换为真实的关键路径测试。
import test from "node:test";
import assert from "node:assert/strict";

test("main module importable", async () => {
  const mod = await import("../src/main.js");
  assert.ok(typeof mod.main === "function");
});
