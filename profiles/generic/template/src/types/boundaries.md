# Boundary Types（边界类型）

模块边界的数据形状定义。外部输入（HTTP body、CLI args、env vars）必须在入口处用这些类型校验。

请根据项目语言选择合适的实现方式：
- Python: dataclass / pydantic BaseModel
- Node/TS: interface / zod schema
- Go: struct with json tags
