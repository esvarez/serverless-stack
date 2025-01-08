package web

import (
	"encoding/json"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
)

type Response events.APIGatewayProxyResponse

// Success returns a response with the given message and status 200
func Success(msg string) Response {
	response := map[string]string{"message": msg}
	return JsonResponse(response, http.StatusOK)
}

func ResponseMsg(msg string, statusCode int) Response {
	response := map[string]string{"message": msg}
	return JsonResponse(response, statusCode)
}

// JsonResponse returns a response with the given status code and marshalled body
// The body is marshalled to json
func JsonResponse(response any, statusCode int) Response {
	body, err := json.Marshal(response)
	if err != nil {
		return Error("error marshalling response")
	}
	return Response{
		StatusCode: statusCode,
		Body:       string(body),
		Headers: map[string]string{
			"Access-Control-Allow-Origin":      "*",
			"Access-Control-Allow-Methods":     "GET, POST, PUT, DELETE, OPTIONS",
			"Access-Control-Allow-Credentials": "true",
		},
	}
}

func Error(msg string) Response {
	return Response{
		StatusCode: http.StatusInternalServerError,
		Body:       msg,
		Headers: map[string]string{
			"Access-Control-Allow-Origin":      "*",
			"Access-Control-Allow-Methods":     "GET, POST, PUT, DELETE, OPTIONS",
			"Access-Control-Allow-Credentials": "true",
		},
	}
}
