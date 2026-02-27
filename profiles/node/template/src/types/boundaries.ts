/** Boundary types — 模块边界的数据形状定义。
 * 外部输入（HTTP body、CLI args、env vars）必须在入口处用这些类型校验。*/

export interface APIResponse {
  status: number;
  message: string;
  data?: Record<string, unknown>;
}
