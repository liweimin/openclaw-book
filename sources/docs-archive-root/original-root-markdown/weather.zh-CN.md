---
name: weather
description: "通过 wttr.in 或 Open-Meteo 获取实时天气与天气预报。适用场景：用户询问任意地点的天气、气温或预报。非适用场景：历史天气、恶劣天气预警、深度气象分析。无需 API Key。"
homepage: https://wttr.in/:help
metadata: { "openclaw": { "emoji": "🌤️", "requires": { "bins": ["curl"] } } }
---

> 原始 `SKILL.md` 的 `description`（英文）  
> `Get current weather and forecasts via wttr.in or Open-Meteo. Use when: user asks about weather, temperature, or forecasts for any location. NOT for: historical weather data, severe weather alerts, or detailed meteorological analysis. No API key needed.`
>
> 对应中文直译  
> `通过 wttr.in 或 Open-Meteo 获取当前天气与天气预报。适用于用户询问任意地点的天气、气温或预报。不适用于历史天气数据、严重天气预警或细粒度气象分析。无需 API Key。`

# Weather Skill

获取当前天气和天气预报。

## 何时使用

✅ **以下场景使用本 skill：**

- “今天天气怎么样？”
- “今天/明天会下雨吗？”
- “某城市现在温度多少？”
- “未来一周天气预报”
- 旅行前天气查询

## 何时不要使用

❌ **以下场景不要使用本 skill：**

- 历史天气数据 -> 使用历史天气数据库/API
- 气候趋势或长期分析 -> 使用专业数据源
- 超本地微气候数据 -> 使用本地传感器
- 严重天气预警 -> 查询官方预警来源
- 航空/海事天气 -> 使用 METAR 等专业服务

## 地点

天气查询一定要带地点（城市、地区或机场代码）。

## 命令

### 当前天气

```bash
# 单行摘要
curl "wttr.in/London?format=3"

# 更详细的当前天气
curl "wttr.in/London?0"

# 指定城市
curl "wttr.in/New+York?format=3"
```

### 预报

```bash
# 3 天天气
curl "wttr.in/London"

# 一周天气
curl "wttr.in/London?format=v2"

# 指定天（0=今天，1=明天，2=后天）
curl "wttr.in/London?1"
```

### 输出格式选项

```bash
# 自定义单行格式
curl "wttr.in/London?format=%l:+%c+%t+%w"

# JSON 输出
curl "wttr.in/London?format=j1"

# PNG 图片输出
curl "wttr.in/London.png"
```

### 格式占位符

- `%c` — 天气状态 emoji
- `%t` — 温度
- `%f` — 体感温度
- `%w` — 风况
- `%h` — 湿度
- `%p` — 降水
- `%l` — 地点

## 快速回复模板

**“天气怎么样？”**

```bash
curl -s "wttr.in/London?format=%l:+%c+%t+(feels+like+%f),+%w+wind,+%h+humidity"
```

**“会下雨吗？”**

```bash
curl -s "wttr.in/London?format=%l:+%c+%p"
```

**“周末天气如何？”**

```bash
curl "wttr.in/London?format=v2"
```

## 备注

- 无需 API Key（默认使用 wttr.in）
- 存在限流，不要高频刷请求
- 支持全球大多数城市
- 支持机场代码，例如：`curl wttr.in/ORD`
