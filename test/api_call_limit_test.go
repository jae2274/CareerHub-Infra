package test

import (
	"net/http"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

// 실제 API 호출 빈도 테스트가 일정한 결과를 보장하지 않음(서버의 물리적 거리, 네트워크 상태 등에 따라 결과가 달라질 수 있음)
// TODO: aws api gateway에 대한 정확한 동작 파악 및 보다 정확한 테스트 방법 필요
func TestApiCallLimit(t *testing.T) {
	testCallLimit(t, 5, "https://careerhub.jyo-liar.com/api/job_postings/count")
	testCallLimit(t, 1, "https://careerhub.jyo-liar.com/")

}

func testCallLimit(t *testing.T, expectedBurstLimit int, url string) {
	statusCodes, errs := callApiBurst(expectedBurstLimit, 1, url)

	if len(errs) > 0 {
		t.Errorf("Error: %v", errs)
	}

	statusCnt := 0

	for _, statusCode := range statusCodes {
		if statusCode == http.StatusTooManyRequests {
			statusCnt++
		}
	}

	require.Equal(t, 0, statusCnt)

	statusCodes, errs = callApiBurst(expectedBurstLimit+2, 2, url)

	if len(errs) > 0 {
		t.Errorf("Error: %v", errs)
	}

	statusCnt = 0

	for _, statusCode := range statusCodes {
		if statusCode == http.StatusTooManyRequests {
			statusCnt++
		}
	}

	require.GreaterOrEqual(t, statusCnt, 1)
}

type Result struct {
	statusCode int
	err        error
}

func resultFail(err error) *Result {
	return &Result{
		statusCode: 0,
		err:        err,
	}
}

func resultSuccess(statusCode int) *Result {
	return &Result{
		statusCode: statusCode,
		err:        nil,
	}
}

func callApiBurst(burstCnt int, afterCnt int, url string) ([]int, []error) {

	httpClient := &http.Client{}

	resultChan := make(chan *Result, 100)

	callApi := func() *Result {
		req, err := http.NewRequest("GET", url, nil)
		if err != nil {
			return resultFail(err)
		}
		resp, err := httpClient.Do(req)
		if err != nil {
			return resultFail(err)
		}

		defer resp.Body.Close()
		return resultSuccess(resp.StatusCode)
	}

	callApiAsync := func() {
		resultChan <- callApi()
	}

	for i := 0; i < burstCnt; i++ {
		go callApiAsync()
	}

	time.Sleep(1 * time.Second)
	for i := 0; i < afterCnt; i++ {
		go callApiAsync()
	}
	time.Sleep(1 * time.Second)

	httpStatusRes := make([]int, 0)
	errRes := make([]error, 0)
	for i := 0; i < (burstCnt + afterCnt); i++ {
		result := <-resultChan
		if result.err != nil {
			errRes = append(errRes, result.err)
		} else {
			httpStatusRes = append(httpStatusRes, result.statusCode)
		}
	}

	return httpStatusRes, errRes
}
