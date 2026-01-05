---
name: test-generator
description: 生成单元测试代码。当用户要求写测试、生成测试用例、添加测试时使用。
allowed-tools: Read, Grep, Glob, Bash
---

# 测试生成器

## 测试原则

### AAA 模式
- **Arrange**: 准备测试数据和环境
- **Act**: 执行被测试的代码
- **Assert**: 验证结果

### 测试覆盖

1. **正常路径** - 预期输入的正常行为
2. **边界条件** - 最小值、最大值、空值
3. **异常情况** - 错误输入、异常处理
4. **边缘案例** - 特殊情况

## 命名规范

```
test_[被测方法]_[场景]_[预期结果]
```

示例:
- `test_login_validCredentials_returnsToken`
- `test_divide_byZero_throwsException`

## 测试模板

### JavaScript (Jest)

```javascript
describe('Calculator', () => {
  describe('add', () => {
    it('should return sum of two positive numbers', () => {
      // Arrange
      const calculator = new Calculator();

      // Act
      const result = calculator.add(2, 3);

      // Assert
      expect(result).toBe(5);
    });

    it('should handle negative numbers', () => {
      const calculator = new Calculator();
      expect(calculator.add(-1, -2)).toBe(-3);
    });

    it('should handle zero', () => {
      const calculator = new Calculator();
      expect(calculator.add(0, 5)).toBe(5);
    });
  });
});
```

### Python (pytest)

```python
import pytest
from calculator import Calculator

class TestCalculator:
    def setup_method(self):
        self.calc = Calculator()

    def test_add_positive_numbers(self):
        # Arrange & Act
        result = self.calc.add(2, 3)

        # Assert
        assert result == 5

    def test_add_negative_numbers(self):
        assert self.calc.add(-1, -2) == -3

    @pytest.mark.parametrize("a,b,expected", [
        (0, 0, 0),
        (1, 0, 1),
        (-1, 1, 0),
    ])
    def test_add_various_inputs(self, a, b, expected):
        assert self.calc.add(a, b) == expected
```

## Mock 使用指南

```javascript
// Mock 外部依赖
jest.mock('./api');
api.fetchUser.mockResolvedValue({ id: 1, name: 'Test' });

// 验证调用
expect(api.fetchUser).toHaveBeenCalledWith(1);
expect(api.fetchUser).toHaveBeenCalledTimes(1);
```

## 检查清单

- [ ] 覆盖所有公共方法
- [ ] 测试边界条件
- [ ] 测试错误处理
- [ ] 测试异步行为
- [ ] Mock 外部依赖
- [ ] 测试命名清晰
