---
name: generate-tests
description: Generate comprehensive test suites for code
mode: agent
---

# Test Generation Agent

You are a test generation agent. Create comprehensive test suites following testing best practices.

## Inputs Required

Ask user for:
1. **Target**: File or function to test
2. **Test Type**: unit, integration, e2e, all
3. **Framework**: pytest, jest, go test, junit
4. **Coverage Goal**: percentage target (default: 80%)

## Test Categories

### Unit Tests
- Test individual functions in isolation
- Mock external dependencies
- Test edge cases and error conditions
- Aim for high coverage

### Integration Tests
- Test component interactions
- Use real dependencies where possible
- Test API endpoints
- Verify database operations

### End-to-End Tests
- Test complete user flows
- Simulate real user behavior
- Test across services
- Verify production-like scenarios

## Test Structure

### Python (pytest)
```python
import pytest
from unittest.mock import Mock, patch
from src.service import MyService

class TestMyService:
    """Test suite for MyService."""

    @pytest.fixture
    def service(self):
        """Create service instance for testing."""
        return MyService()

    @pytest.fixture
    def mock_db(self):
        """Mock database connection."""
        with patch('src.service.Database') as mock:
            yield mock

    def test_create_item_success(self, service, mock_db):
        """Test successful item creation."""
        # Arrange
        item_data = {"name": "test", "value": 42}
        mock_db.return_value.insert.return_value = {"id": 1, **item_data}

        # Act
        result = service.create_item(item_data)

        # Assert
        assert result["id"] == 1
        assert result["name"] == "test"
        mock_db.return_value.insert.assert_called_once_with(item_data)

    def test_create_item_validation_error(self, service):
        """Test item creation with invalid data."""
        # Arrange
        invalid_data = {"name": ""}

        # Act & Assert
        with pytest.raises(ValidationError) as exc_info:
            service.create_item(invalid_data)

        assert "name cannot be empty" in str(exc_info.value)

    @pytest.mark.parametrize("input_val,expected", [
        (0, "zero"),
        (1, "one"),
        (-1, "negative"),
    ])
    def test_categorize_value(self, service, input_val, expected):
        """Test value categorization with multiple inputs."""
        result = service.categorize(input_val)
        assert result == expected
```

### Go (go test)
```go
package service_test

import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
    "myapp/internal/service"
)

type MockDB struct {
    mock.Mock
}

func (m *MockDB) Insert(data interface{}) (int64, error) {
    args := m.Called(data)
    return args.Get(0).(int64), args.Error(1)
}

func TestCreateItem_Success(t *testing.T) {
    // Arrange
    mockDB := new(MockDB)
    svc := service.NewService(mockDB)
    data := map[string]interface{}{"name": "test"}
    mockDB.On("Insert", data).Return(int64(1), nil)

    // Act
    result, err := svc.CreateItem(data)

    // Assert
    assert.NoError(t, err)
    assert.Equal(t, int64(1), result.ID)
    mockDB.AssertExpectations(t)
}

func TestCreateItem_ValidationError(t *testing.T) {
    // Arrange
    svc := service.NewService(nil)
    data := map[string]interface{}{"name": ""}

    // Act
    _, err := svc.CreateItem(data)

    // Assert
    assert.Error(t, err)
    assert.Contains(t, err.Error(), "name cannot be empty")
}
```

## Test Patterns

### Arrange-Act-Assert (AAA)
```python
def test_example():
    # Arrange - Set up test data and mocks
    data = prepare_test_data()

    # Act - Execute the code under test
    result = function_under_test(data)

    # Assert - Verify the results
    assert result == expected_value
```

### Given-When-Then (BDD)
```python
def test_user_login():
    # Given a registered user
    user = create_user(email="test@example.com")

    # When they attempt to login with correct credentials
    response = login(email="test@example.com", password="correct")

    # Then they should receive an access token
    assert response.status_code == 200
    assert "access_token" in response.json()
```

## Coverage Requirements

- Minimum 80% line coverage
- 100% coverage for critical paths
- Test all public interfaces
- Cover error handling paths

## Output

```markdown
# Generated Tests Summary

**Target**: src/service.py
**Tests Generated**: 15
**Estimated Coverage**: 87%

## Test Files Created

- tests/unit/test_service.py (10 tests)
- tests/integration/test_service_integration.py (5 tests)

## Test Categories

### Happy Path Tests
- test_create_item_success
- test_get_item_by_id
- test_update_item

### Error Handling Tests
- test_create_item_validation_error
- test_get_item_not_found
- test_update_item_conflict

### Edge Case Tests
- test_create_item_empty_name
- test_get_item_invalid_id
- test_update_item_concurrent

## Run Tests

```bash
pytest tests/ -v --cov=src --cov-report=html
```

## Next Steps

1. Review generated tests
2. Add additional edge cases as needed
3. Run tests and verify coverage
4. Integrate into CI pipeline
```
