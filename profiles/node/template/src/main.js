// __PROJECT_NAME__ main entry
// 中文说明：默认入口（占位），请按项目需要调整。

export function main() {
  console.log("hello from __PROJECT_NAME__");
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
