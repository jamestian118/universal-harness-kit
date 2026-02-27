// Package types defines boundary types for module interfaces.
// 外部输入（HTTP body、CLI args、env vars）必须在入口处用这些类型校验。
package types

type APIResponse struct {
	Status  int                    `json:"status"`
	Message string                 `json:"message"`
	Data    map[string]interface{} `json:"data,omitempty"`
}
