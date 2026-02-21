// 冒烟测试：验证项目基本可用。新建项目后请替换为真实的关键路径测试。
package main

import (
	"os/exec"
	"testing"
)

func TestMainBuilds(t *testing.T) {
	// 验证 src/main.go 能正常编译，证明项目结构和依赖没有破损
	cmd := exec.Command("go", "build", "./src")
	if out, err := cmd.CombinedOutput(); err != nil {
		t.Fatalf("go build ./src failed: %v\n%s", err, out)
	}
}
