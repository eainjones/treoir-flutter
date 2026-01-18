#!/bin/bash

###############################################################################
# Treoir Routines API Test Script
#
# Comprehensive test suite for the Routines API endpoints.
# Tests all CRUD operations, error handling, and cleanup.
#
# Usage: ./test-routines-api.sh [BASE_URL]
#        BASE_URL defaults to https://staging.treoir.xyz/api/v1
###############################################################################

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================

# API Base URL (can be overridden via command line argument)
BASE_URL="${1:-https://staging.treoir.xyz/api/v1}"

# Supabase configuration
SUPABASE_URL="https://phifyhudywiuqgwezumh.supabase.co"
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoaWZ5aHVkeXdpdXFnd2V6dW1oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI2MTIxNzgsImV4cCI6MjA3ODE4ODE3OH0.VC_keEUD3OAxfrss0TI5EAQvwkkB_wU2D67KH-3mA48"

# Test credentials
TEST_EMAIL="test@treoir.xyz"
TEST_PASSWORD="TreoirTest2025!"

# Test data tracking (for cleanup)
CREATED_ROUTINE_IDS=()
CREATED_WORKOUT_IDS=()

# =============================================================================
# Colors and Formatting
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# =============================================================================
# Counters
# =============================================================================

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# =============================================================================
# Utility Functions
# =============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}${BOLD}========================================${NC}"
    echo -e "${BLUE}${BOLD}$1${NC}"
    echo -e "${BLUE}${BOLD}========================================${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${CYAN}--- $1 ---${NC}"
    echo ""
}

print_test() {
    echo -e "${BOLD}TEST:${NC} $1"
}

print_pass() {
    echo -e "  ${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

print_fail() {
    echo -e "  ${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

print_skip() {
    echo -e "  ${YELLOW}[SKIP]${NC} $1"
    ((TESTS_SKIPPED++))
}

print_info() {
    echo -e "  ${BLUE}[INFO]${NC} $1"
}

print_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DEBUG]${NC} $1"
    fi
}

# Check if jq is installed
check_dependencies() {
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: jq is required but not installed.${NC}"
        echo "Install with: brew install jq"
        exit 1
    fi

    if ! command -v curl &> /dev/null; then
        echo -e "${RED}Error: curl is required but not installed.${NC}"
        exit 1
    fi
}

# Make HTTP request and capture response
http_request() {
    local method="$1"
    local endpoint="$2"
    local data="${3:-}"
    local auth_header="${4:-}"
    local extra_headers="${5:-}"

    local url="${BASE_URL}${endpoint}"
    local curl_args=(-s -w "\n%{http_code}" -X "$method")

    # Add headers
    curl_args+=(-H "Content-Type: application/json")

    if [[ -n "$auth_header" ]]; then
        curl_args+=(-H "Authorization: Bearer $auth_header")
    fi

    if [[ -n "$extra_headers" ]]; then
        curl_args+=(-H "$extra_headers")
    fi

    # Add data for POST/PATCH/PUT
    if [[ -n "$data" ]]; then
        curl_args+=(-d "$data")
    fi

    curl_args+=("$url")

    print_debug "curl ${curl_args[*]}"

    local response
    response=$(curl "${curl_args[@]}" 2>/dev/null)

    echo "$response"
}

# Extract HTTP status code from response
get_status_code() {
    echo "$1" | tail -n1
}

# Extract response body from response
get_body() {
    echo "$1" | sed '$d'
}

# Assert HTTP status code
assert_status() {
    local response="$1"
    local expected="$2"
    local test_name="$3"

    local status
    status=$(get_status_code "$response")

    if [[ "$status" == "$expected" ]]; then
        print_pass "$test_name (HTTP $status)"
        return 0
    else
        print_fail "$test_name (Expected HTTP $expected, got HTTP $status)"
        local body
        body=$(get_body "$response")
        print_info "Response: $body"
        return 1
    fi
}

# Assert JSON field exists
assert_json_field() {
    local body="$1"
    local field="$2"
    local test_name="$3"

    if echo "$body" | jq -e "$field" > /dev/null 2>&1; then
        print_pass "$test_name"
        return 0
    else
        print_fail "$test_name (Field $field not found)"
        return 1
    fi
}

# Assert JSON field equals value
assert_json_equals() {
    local body="$1"
    local field="$2"
    local expected="$3"
    local test_name="$4"

    local actual
    actual=$(echo "$body" | jq -r "$field" 2>/dev/null)

    if [[ "$actual" == "$expected" ]]; then
        print_pass "$test_name"
        return 0
    else
        print_fail "$test_name (Expected '$expected', got '$actual')"
        return 1
    fi
}

# =============================================================================
# Authentication
# =============================================================================

AUTH_TOKEN=""

get_auth_token() {
    print_section "Authenticating with Supabase"

    local auth_url="${SUPABASE_URL}/auth/v1/token?grant_type=password"

    local response
    response=$(curl -s -w "\n%{http_code}" -X POST "$auth_url" \
        -H "apikey: $ANON_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"email\": \"$TEST_EMAIL\", \"password\": \"$TEST_PASSWORD\"}")

    local status
    status=$(get_status_code "$response")
    local body
    body=$(get_body "$response")

    if [[ "$status" == "200" ]]; then
        AUTH_TOKEN=$(echo "$body" | jq -r '.access_token')
        if [[ -n "$AUTH_TOKEN" && "$AUTH_TOKEN" != "null" ]]; then
            print_pass "Authentication successful"
            print_info "Token: ${AUTH_TOKEN:0:50}..."
            return 0
        else
            print_fail "Failed to extract access token"
            print_info "Response: $body"
            return 1
        fi
    else
        print_fail "Authentication failed (HTTP $status)"
        print_info "Response: $body"
        return 1
    fi
}

# =============================================================================
# Cleanup Function
# =============================================================================

cleanup() {
    print_header "CLEANUP"

    # Clean up created routines
    for routine_id in "${CREATED_ROUTINE_IDS[@]}"; do
        print_info "Deleting routine: $routine_id"
        local response
        response=$(http_request "DELETE" "/routines/$routine_id" "" "$AUTH_TOKEN")
        local status
        status=$(get_status_code "$response")
        if [[ "$status" == "200" || "$status" == "204" || "$status" == "404" ]]; then
            print_info "  Deleted (or already gone)"
        else
            print_info "  Warning: Could not delete (HTTP $status)"
        fi
    done

    # Clean up created workouts
    for workout_id in "${CREATED_WORKOUT_IDS[@]}"; do
        print_info "Deleting workout: $workout_id"
        local response
        response=$(http_request "DELETE" "/workouts/$workout_id" "" "$AUTH_TOKEN")
        local status
        status=$(get_status_code "$response")
        if [[ "$status" == "200" || "$status" == "204" || "$status" == "404" ]]; then
            print_info "  Deleted (or already gone)"
        else
            print_info "  Warning: Could not delete (HTTP $status)"
        fi
    done

    print_info "Cleanup complete"
}

# Set trap to ensure cleanup runs on exit
trap cleanup EXIT

# =============================================================================
# Test Cases - Unauthorized Access (401 Tests)
# =============================================================================

test_unauthorized_access() {
    print_header "UNAUTHORIZED ACCESS TESTS (401)"

    print_test "GET /routines without auth token"
    local response
    response=$(http_request "GET" "/routines")
    assert_status "$response" "401" "Should return 401 Unauthorized" || true

    print_test "GET /routines/:id without auth token"
    response=$(http_request "GET" "/routines/00000000-0000-0000-0000-000000000000")
    assert_status "$response" "401" "Should return 401 Unauthorized" || true

    print_test "POST /routines without auth token"
    response=$(http_request "POST" "/routines" '{"name": "Unauthorized Routine"}')
    assert_status "$response" "401" "Should return 401 Unauthorized" || true

    print_test "PATCH /routines/:id without auth token"
    response=$(http_request "PATCH" "/routines/00000000-0000-0000-0000-000000000000" '{"name": "Updated"}')
    assert_status "$response" "401" "Should return 401 Unauthorized" || true

    print_test "DELETE /routines/:id without auth token"
    response=$(http_request "DELETE" "/routines/00000000-0000-0000-0000-000000000000")
    assert_status "$response" "401" "Should return 401 Unauthorized" || true

    print_test "POST /routines/:id/start without auth token"
    response=$(http_request "POST" "/routines/00000000-0000-0000-0000-000000000000/start")
    assert_status "$response" "401" "Should return 401 Unauthorized" || true
}

# =============================================================================
# Test Cases - Not Found (404 Tests)
# =============================================================================

test_not_found() {
    print_header "NOT FOUND TESTS (404)"

    local fake_uuid="00000000-0000-0000-0000-000000000000"

    print_test "GET /routines/:id with non-existent ID"
    local response
    response=$(http_request "GET" "/routines/$fake_uuid" "" "$AUTH_TOKEN")
    assert_status "$response" "404" "Should return 404 Not Found" || true

    print_test "PATCH /routines/:id with non-existent ID"
    response=$(http_request "PATCH" "/routines/$fake_uuid" '{"name": "Updated"}' "$AUTH_TOKEN")
    assert_status "$response" "404" "Should return 404 Not Found" || true

    print_test "DELETE /routines/:id with non-existent ID"
    response=$(http_request "DELETE" "/routines/$fake_uuid" "" "$AUTH_TOKEN")
    assert_status "$response" "404" "Should return 404 Not Found" || true

    print_test "POST /routines/:id/start with non-existent ID"
    response=$(http_request "POST" "/routines/$fake_uuid/start" "" "$AUTH_TOKEN")
    assert_status "$response" "404" "Should return 404 Not Found" || true
}

# =============================================================================
# Test Cases - Validation Errors (400 Tests)
# =============================================================================

test_validation_errors() {
    print_header "VALIDATION ERROR TESTS (400)"

    print_test "POST /routines with empty body"
    local response
    response=$(http_request "POST" "/routines" '{}' "$AUTH_TOKEN")
    assert_status "$response" "400" "Should return 400 Bad Request for missing name" || true

    print_test "POST /routines with empty name"
    response=$(http_request "POST" "/routines" '{"name": ""}' "$AUTH_TOKEN")
    assert_status "$response" "400" "Should return 400 Bad Request for empty name" || true

    print_test "POST /routines with invalid estimatedDuration type"
    response=$(http_request "POST" "/routines" '{"name": "Test", "estimatedDuration": "not-a-number"}' "$AUTH_TOKEN")
    assert_status "$response" "400" "Should return 400 Bad Request for invalid duration type" || true

    print_test "POST /routines with negative estimatedDuration"
    response=$(http_request "POST" "/routines" '{"name": "Test", "estimatedDuration": -10}' "$AUTH_TOKEN")
    assert_status "$response" "400" "Should return 400 Bad Request for negative duration" || true

    print_test "PATCH /routines/:id with invalid JSON"
    # First create a routine to update
    response=$(http_request "POST" "/routines" '{"name": "Temp Routine for Validation"}' "$AUTH_TOKEN")
    local status
    status=$(get_status_code "$response")
    if [[ "$status" == "200" || "$status" == "201" ]]; then
        local body
        body=$(get_body "$response")
        local routine_id
        routine_id=$(echo "$body" | jq -r '.data.id // .id')
        if [[ -n "$routine_id" && "$routine_id" != "null" ]]; then
            CREATED_ROUTINE_IDS+=("$routine_id")

            # Now try to update with invalid JSON
            response=$(curl -s -w "\n%{http_code}" -X PATCH "${BASE_URL}/routines/$routine_id" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer $AUTH_TOKEN" \
                -d '{invalid json}')
            assert_status "$response" "400" "Should return 400 Bad Request for invalid JSON" || true
        else
            print_skip "Could not extract routine ID for validation test"
        fi
    else
        print_skip "Could not create routine for validation test"
    fi
}

# =============================================================================
# Test Cases - List Routines
# =============================================================================

test_list_routines() {
    print_header "LIST ROUTINES TESTS (GET /routines)"

    print_test "List all routines"
    local response
    response=$(http_request "GET" "/routines" "" "$AUTH_TOKEN")
    local status
    status=$(get_status_code "$response")
    local body
    body=$(get_body "$response")

    if assert_status "$response" "200" "Should return 200 OK"; then
        assert_json_field "$body" '.data' "Response should contain 'data' array" || true
        assert_json_field "$body" '.meta' "Response should contain 'meta' object" || true
        assert_json_field "$body" '.meta.page' "Meta should contain 'page'" || true
        assert_json_field "$body" '.meta.pageSize' "Meta should contain 'pageSize'" || true
        assert_json_field "$body" '.meta.total' "Meta should contain 'total'" || true
        assert_json_field "$body" '.meta.hasMore' "Meta should contain 'hasMore'" || true
    fi

    print_test "List routines with pagination (page=1, pageSize=5)"
    response=$(http_request "GET" "/routines?page=1&pageSize=5" "" "$AUTH_TOKEN")
    if assert_status "$response" "200" "Should return 200 OK"; then
        body=$(get_body "$response")
        local page_size
        page_size=$(echo "$body" | jq -r '.meta.pageSize')
        if [[ "$page_size" == "5" ]]; then
            print_pass "pageSize is correctly set to 5"
        else
            print_fail "pageSize should be 5, got $page_size"
        fi
    fi

    print_test "List routines with large page number"
    response=$(http_request "GET" "/routines?page=9999" "" "$AUTH_TOKEN")
    if assert_status "$response" "200" "Should return 200 OK (empty results)"; then
        body=$(get_body "$response")
        local count
        count=$(echo "$body" | jq '.data | length')
        print_info "Returned $count routines for page 9999"
    fi
}

# =============================================================================
# Test Cases - Create Routine
# =============================================================================

test_create_routine() {
    print_header "CREATE ROUTINE TESTS (POST /routines)"

    local test_name="API Test Routine $(date +%s)"

    print_test "Create routine with name only"
    local response
    response=$(http_request "POST" "/routines" "{\"name\": \"$test_name\"}" "$AUTH_TOKEN")
    local status
    status=$(get_status_code "$response")
    local body
    body=$(get_body "$response")

    if [[ "$status" == "200" || "$status" == "201" ]]; then
        print_pass "Routine created successfully (HTTP $status)"

        local routine_id
        routine_id=$(echo "$body" | jq -r '.data.id // .id')
        if [[ -n "$routine_id" && "$routine_id" != "null" ]]; then
            CREATED_ROUTINE_IDS+=("$routine_id")
            print_info "Created routine ID: $routine_id"

            assert_json_equals "$body" '.data.name // .name' "$test_name" "Name should match" || true
            assert_json_field "$body" '.data.id // .id' "Response should contain 'id'" || true
        else
            print_fail "Could not extract routine ID from response"
        fi
    else
        print_fail "Failed to create routine (HTTP $status)"
        print_info "Response: $body"
    fi

    print_test "Create routine with name and estimatedDuration"
    test_name="API Test Routine with Duration $(date +%s)"
    response=$(http_request "POST" "/routines" "{\"name\": \"$test_name\", \"estimatedDuration\": 45}" "$AUTH_TOKEN")
    status=$(get_status_code "$response")
    body=$(get_body "$response")

    if [[ "$status" == "200" || "$status" == "201" ]]; then
        print_pass "Routine with duration created successfully (HTTP $status)"

        local routine_id
        routine_id=$(echo "$body" | jq -r '.data.id // .id')
        if [[ -n "$routine_id" && "$routine_id" != "null" ]]; then
            CREATED_ROUTINE_IDS+=("$routine_id")
            print_info "Created routine ID: $routine_id"

            local duration
            duration=$(echo "$body" | jq -r '.data.estimatedDuration // .estimatedDuration')
            if [[ "$duration" == "45" ]]; then
                print_pass "Estimated duration is correctly set to 45"
            else
                print_fail "Estimated duration should be 45, got $duration"
            fi
        fi
    else
        print_fail "Failed to create routine with duration (HTTP $status)"
        print_info "Response: $body"
    fi
}

# =============================================================================
# Test Cases - Get Routine Detail
# =============================================================================

DETAIL_TEST_ROUTINE_ID=""

test_get_routine_detail() {
    print_header "GET ROUTINE DETAIL TESTS (GET /routines/:id)"

    # First create a routine to test with
    print_test "Setup: Create routine for detail tests"
    local test_name="Detail Test Routine $(date +%s)"
    local response
    response=$(http_request "POST" "/routines" "{\"name\": \"$test_name\", \"estimatedDuration\": 30}" "$AUTH_TOKEN")
    local status
    status=$(get_status_code "$response")
    local body
    body=$(get_body "$response")

    if [[ "$status" == "200" || "$status" == "201" ]]; then
        DETAIL_TEST_ROUTINE_ID=$(echo "$body" | jq -r '.data.id // .id')
        if [[ -n "$DETAIL_TEST_ROUTINE_ID" && "$DETAIL_TEST_ROUTINE_ID" != "null" ]]; then
            CREATED_ROUTINE_IDS+=("$DETAIL_TEST_ROUTINE_ID")
            print_pass "Created test routine: $DETAIL_TEST_ROUTINE_ID"
        else
            print_skip "Could not create test routine for detail tests"
            return
        fi
    else
        print_skip "Could not create test routine for detail tests"
        return
    fi

    print_test "Get routine by ID"
    response=$(http_request "GET" "/routines/$DETAIL_TEST_ROUTINE_ID" "" "$AUTH_TOKEN")
    status=$(get_status_code "$response")
    body=$(get_body "$response")

    if assert_status "$response" "200" "Should return 200 OK"; then
        assert_json_field "$body" '.data.id // .id' "Response should contain 'id'" || true
        assert_json_field "$body" '.data.name // .name' "Response should contain 'name'" || true
        assert_json_equals "$body" '.data.name // .name' "$test_name" "Name should match created routine" || true

        # Check for exercises array (even if empty)
        if echo "$body" | jq -e '.data.exercises // .exercises' > /dev/null 2>&1; then
            print_pass "Response contains 'exercises' array"
        else
            print_info "Response does not include 'exercises' (may be omitted when empty)"
        fi
    fi

    print_test "Get routine with invalid UUID format"
    response=$(http_request "GET" "/routines/not-a-valid-uuid" "" "$AUTH_TOKEN")
    status=$(get_status_code "$response")
    if [[ "$status" == "400" || "$status" == "404" ]]; then
        print_pass "Returns error for invalid UUID (HTTP $status)"
    else
        print_fail "Should return 400 or 404 for invalid UUID, got HTTP $status"
    fi
}

# =============================================================================
# Test Cases - Update Routine
# =============================================================================

test_update_routine() {
    print_header "UPDATE ROUTINE TESTS (PATCH /routines/:id)"

    # Create a routine to update
    print_test "Setup: Create routine for update tests"
    local test_name="Update Test Routine $(date +%s)"
    local response
    response=$(http_request "POST" "/routines" "{\"name\": \"$test_name\"}" "$AUTH_TOKEN")
    local status
    status=$(get_status_code "$response")
    local body
    body=$(get_body "$response")

    local update_routine_id=""
    if [[ "$status" == "200" || "$status" == "201" ]]; then
        update_routine_id=$(echo "$body" | jq -r '.data.id // .id')
        if [[ -n "$update_routine_id" && "$update_routine_id" != "null" ]]; then
            CREATED_ROUTINE_IDS+=("$update_routine_id")
            print_pass "Created test routine: $update_routine_id"
        else
            print_skip "Could not create test routine for update tests"
            return
        fi
    else
        print_skip "Could not create test routine for update tests"
        return
    fi

    print_test "Update routine name"
    local updated_name="Updated Routine Name $(date +%s)"
    response=$(http_request "PATCH" "/routines/$update_routine_id" "{\"name\": \"$updated_name\"}" "$AUTH_TOKEN")
    status=$(get_status_code "$response")
    body=$(get_body "$response")

    if assert_status "$response" "200" "Should return 200 OK"; then
        assert_json_equals "$body" '.data.name // .name' "$updated_name" "Name should be updated" || true
    fi

    print_test "Update routine estimatedDuration"
    response=$(http_request "PATCH" "/routines/$update_routine_id" '{"estimatedDuration": 60}' "$AUTH_TOKEN")
    status=$(get_status_code "$response")
    body=$(get_body "$response")

    if assert_status "$response" "200" "Should return 200 OK"; then
        local duration
        duration=$(echo "$body" | jq -r '.data.estimatedDuration // .estimatedDuration')
        if [[ "$duration" == "60" ]]; then
            print_pass "Estimated duration updated to 60"
        else
            print_fail "Estimated duration should be 60, got $duration"
        fi
    fi

    print_test "Update routine with multiple fields"
    local multi_name="Multi Update Test $(date +%s)"
    response=$(http_request "PATCH" "/routines/$update_routine_id" "{\"name\": \"$multi_name\", \"estimatedDuration\": 90}" "$AUTH_TOKEN")
    status=$(get_status_code "$response")
    body=$(get_body "$response")

    if assert_status "$response" "200" "Should return 200 OK"; then
        assert_json_equals "$body" '.data.name // .name' "$multi_name" "Name should be updated" || true
        local duration
        duration=$(echo "$body" | jq -r '.data.estimatedDuration // .estimatedDuration')
        if [[ "$duration" == "90" ]]; then
            print_pass "Estimated duration updated to 90"
        else
            print_fail "Estimated duration should be 90, got $duration"
        fi
    fi

    print_test "Update routine with empty update body"
    response=$(http_request "PATCH" "/routines/$update_routine_id" '{}' "$AUTH_TOKEN")
    status=$(get_status_code "$response")
    if [[ "$status" == "200" ]]; then
        print_pass "Empty update returns 200 (no-op)"
    elif [[ "$status" == "400" ]]; then
        print_pass "Empty update returns 400 (validation)"
    else
        print_fail "Unexpected status for empty update: HTTP $status"
    fi
}

# =============================================================================
# Test Cases - Delete Routine
# =============================================================================

test_delete_routine() {
    print_header "DELETE ROUTINE TESTS (DELETE /routines/:id)"

    # Create a routine to delete
    print_test "Setup: Create routine for delete test"
    local test_name="Delete Test Routine $(date +%s)"
    local response
    response=$(http_request "POST" "/routines" "{\"name\": \"$test_name\"}" "$AUTH_TOKEN")
    local status
    status=$(get_status_code "$response")
    local body
    body=$(get_body "$response")

    local delete_routine_id=""
    if [[ "$status" == "200" || "$status" == "201" ]]; then
        delete_routine_id=$(echo "$body" | jq -r '.data.id // .id')
        if [[ -n "$delete_routine_id" && "$delete_routine_id" != "null" ]]; then
            print_pass "Created test routine: $delete_routine_id"
        else
            print_skip "Could not create test routine for delete tests"
            return
        fi
    else
        print_skip "Could not create test routine for delete tests"
        return
    fi

    print_test "Delete routine"
    response=$(http_request "DELETE" "/routines/$delete_routine_id" "" "$AUTH_TOKEN")
    status=$(get_status_code "$response")

    if [[ "$status" == "200" || "$status" == "204" ]]; then
        print_pass "Routine deleted successfully (HTTP $status)"
    else
        print_fail "Failed to delete routine (HTTP $status)"
        # Add to cleanup list in case of failure
        CREATED_ROUTINE_IDS+=("$delete_routine_id")
    fi

    print_test "Verify routine is deleted (GET should return 404)"
    response=$(http_request "GET" "/routines/$delete_routine_id" "" "$AUTH_TOKEN")
    assert_status "$response" "404" "Deleted routine should return 404" || true

    print_test "Delete already deleted routine (idempotent)"
    response=$(http_request "DELETE" "/routines/$delete_routine_id" "" "$AUTH_TOKEN")
    status=$(get_status_code "$response")
    if [[ "$status" == "404" || "$status" == "200" || "$status" == "204" ]]; then
        print_pass "Deleting non-existent routine handles gracefully (HTTP $status)"
    else
        print_fail "Unexpected status when deleting non-existent routine: HTTP $status"
    fi
}

# =============================================================================
# Test Cases - Start Workout from Routine
# =============================================================================

test_start_workout() {
    print_header "START WORKOUT TESTS (POST /routines/:id/start)"

    # Create a routine to start
    print_test "Setup: Create routine for start workout test"
    local test_name="Start Workout Test Routine $(date +%s)"
    local response
    response=$(http_request "POST" "/routines" "{\"name\": \"$test_name\", \"estimatedDuration\": 45}" "$AUTH_TOKEN")
    local status
    status=$(get_status_code "$response")
    local body
    body=$(get_body "$response")

    local start_routine_id=""
    if [[ "$status" == "200" || "$status" == "201" ]]; then
        start_routine_id=$(echo "$body" | jq -r '.data.id // .id')
        if [[ -n "$start_routine_id" && "$start_routine_id" != "null" ]]; then
            CREATED_ROUTINE_IDS+=("$start_routine_id")
            print_pass "Created test routine: $start_routine_id"
        else
            print_skip "Could not create test routine for start workout tests"
            return
        fi
    else
        print_skip "Could not create test routine for start workout tests"
        return
    fi

    print_test "Start workout from routine"
    response=$(http_request "POST" "/routines/$start_routine_id/start" "" "$AUTH_TOKEN")
    status=$(get_status_code "$response")
    body=$(get_body "$response")

    if [[ "$status" == "200" || "$status" == "201" ]]; then
        print_pass "Workout started successfully (HTTP $status)"

        local workout_id
        workout_id=$(echo "$body" | jq -r '.data.id // .id')
        if [[ -n "$workout_id" && "$workout_id" != "null" ]]; then
            CREATED_WORKOUT_IDS+=("$workout_id")
            print_info "Created workout ID: $workout_id"

            # Verify workout has reference to routine
            local routine_ref
            routine_ref=$(echo "$body" | jq -r '.data.routineId // .data.routine.id // .routineId // .routine.id // empty')
            if [[ -n "$routine_ref" ]]; then
                if [[ "$routine_ref" == "$start_routine_id" ]]; then
                    print_pass "Workout references correct routine"
                else
                    print_info "Workout routine reference: $routine_ref"
                fi
            else
                print_info "Workout does not include routine reference in response"
            fi

            # Verify workout is in progress (no completedAt)
            local completed_at
            completed_at=$(echo "$body" | jq -r '.data.completedAt // .completedAt // empty')
            if [[ -z "$completed_at" || "$completed_at" == "null" ]]; then
                print_pass "Workout is in progress (not completed)"
            else
                print_info "Workout has completedAt set: $completed_at"
            fi
        fi
    else
        print_fail "Failed to start workout (HTTP $status)"
        print_info "Response: $body"
    fi

    print_test "Start another workout from same routine (should be allowed)"
    response=$(http_request "POST" "/routines/$start_routine_id/start" "" "$AUTH_TOKEN")
    status=$(get_status_code "$response")
    body=$(get_body "$response")

    if [[ "$status" == "200" || "$status" == "201" ]]; then
        print_pass "Second workout started successfully (HTTP $status)"
        local workout_id
        workout_id=$(echo "$body" | jq -r '.data.id // .id')
        if [[ -n "$workout_id" && "$workout_id" != "null" ]]; then
            CREATED_WORKOUT_IDS+=("$workout_id")
        fi
    elif [[ "$status" == "409" ]]; then
        print_info "API prevents multiple active workouts (HTTP 409 Conflict)"
        print_pass "Conflict handling is correct"
    else
        print_fail "Unexpected status for second workout: HTTP $status"
        print_info "Response: $body"
    fi
}

# =============================================================================
# Test Cases - Edge Cases
# =============================================================================

test_edge_cases() {
    print_header "EDGE CASE TESTS"

    print_test "Create routine with very long name (255 chars)"
    local long_name
    long_name=$(printf 'A%.0s' {1..255})
    local response
    response=$(http_request "POST" "/routines" "{\"name\": \"$long_name\"}" "$AUTH_TOKEN")
    local status
    status=$(get_status_code "$response")
    local body
    body=$(get_body "$response")

    if [[ "$status" == "200" || "$status" == "201" ]]; then
        local routine_id
        routine_id=$(echo "$body" | jq -r '.data.id // .id')
        if [[ -n "$routine_id" && "$routine_id" != "null" ]]; then
            CREATED_ROUTINE_IDS+=("$routine_id")
            print_pass "Long name accepted (HTTP $status)"
        fi
    elif [[ "$status" == "400" ]]; then
        print_pass "Long name rejected with validation error (HTTP 400)"
    else
        print_info "Unexpected status for long name: HTTP $status"
    fi

    print_test "Create routine with special characters in name"
    local special_name="Test Routine <>&\"'!@#\$%^*()_+-=[]{}|;:,.?/ $(date +%s)"
    response=$(http_request "POST" "/routines" "{\"name\": \"$special_name\"}" "$AUTH_TOKEN")
    status=$(get_status_code "$response")
    body=$(get_body "$response")

    if [[ "$status" == "200" || "$status" == "201" ]]; then
        local routine_id
        routine_id=$(echo "$body" | jq -r '.data.id // .id')
        if [[ -n "$routine_id" && "$routine_id" != "null" ]]; then
            CREATED_ROUTINE_IDS+=("$routine_id")
            print_pass "Special characters accepted (HTTP $status)"
        fi
    elif [[ "$status" == "400" ]]; then
        print_pass "Special characters rejected with validation (HTTP 400)"
    else
        print_info "Unexpected status for special chars: HTTP $status"
    fi

    print_test "Create routine with Unicode characters"
    local unicode_name="Test Routine with emojis and accents: cafe Routine $(date +%s)"
    response=$(http_request "POST" "/routines" "{\"name\": \"$unicode_name\"}" "$AUTH_TOKEN")
    status=$(get_status_code "$response")
    body=$(get_body "$response")

    if [[ "$status" == "200" || "$status" == "201" ]]; then
        local routine_id
        routine_id=$(echo "$body" | jq -r '.data.id // .id')
        if [[ -n "$routine_id" && "$routine_id" != "null" ]]; then
            CREATED_ROUTINE_IDS+=("$routine_id")
            print_pass "Unicode characters accepted (HTTP $status)"
        fi
    elif [[ "$status" == "400" ]]; then
        print_pass "Unicode characters handled (HTTP 400)"
    else
        print_info "Unexpected status for unicode: HTTP $status"
    fi

    print_test "Create routine with zero estimatedDuration"
    response=$(http_request "POST" "/routines" '{"name": "Zero Duration Test", "estimatedDuration": 0}' "$AUTH_TOKEN")
    status=$(get_status_code "$response")
    body=$(get_body "$response")

    if [[ "$status" == "200" || "$status" == "201" ]]; then
        local routine_id
        routine_id=$(echo "$body" | jq -r '.data.id // .id')
        if [[ -n "$routine_id" && "$routine_id" != "null" ]]; then
            CREATED_ROUTINE_IDS+=("$routine_id")
            print_pass "Zero duration accepted (HTTP $status)"
        fi
    elif [[ "$status" == "400" ]]; then
        print_pass "Zero duration rejected (HTTP 400)"
    else
        print_info "Unexpected status for zero duration: HTTP $status"
    fi

    print_test "Create routine with very large estimatedDuration"
    response=$(http_request "POST" "/routines" '{"name": "Large Duration Test", "estimatedDuration": 999999}' "$AUTH_TOKEN")
    status=$(get_status_code "$response")
    body=$(get_body "$response")

    if [[ "$status" == "200" || "$status" == "201" ]]; then
        local routine_id
        routine_id=$(echo "$body" | jq -r '.data.id // .id')
        if [[ -n "$routine_id" && "$routine_id" != "null" ]]; then
            CREATED_ROUTINE_IDS+=("$routine_id")
            print_pass "Large duration accepted (HTTP $status)"
        fi
    elif [[ "$status" == "400" ]]; then
        print_pass "Large duration rejected (HTTP 400)"
    else
        print_info "Unexpected status for large duration: HTTP $status"
    fi
}

# =============================================================================
# Print Summary
# =============================================================================

print_summary() {
    print_header "TEST SUMMARY"

    local total=$((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))

    echo -e "${BOLD}Total Tests:${NC} $total"
    echo -e "${GREEN}Passed:${NC}      $TESTS_PASSED"
    echo -e "${RED}Failed:${NC}      $TESTS_FAILED"
    echo -e "${YELLOW}Skipped:${NC}     $TESTS_SKIPPED"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}${BOLD}Some tests failed.${NC}"
        return 1
    fi
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    print_header "TREOIR ROUTINES API TEST SUITE"
    echo -e "${BOLD}API Base URL:${NC} $BASE_URL"
    echo -e "${BOLD}Started at:${NC}  $(date)"
    echo ""

    # Check dependencies
    check_dependencies

    # Authenticate
    if ! get_auth_token; then
        echo -e "${RED}${BOLD}Authentication failed. Cannot continue.${NC}"
        exit 1
    fi

    # Run test suites
    test_unauthorized_access
    test_not_found
    test_validation_errors
    test_list_routines
    test_create_routine
    test_get_routine_detail
    test_update_routine
    test_delete_routine
    test_start_workout
    test_edge_cases

    # Print summary (cleanup happens via trap)
    print_summary
}

# Run main function
main "$@"
