import http from "k6/http";
import { check, sleep } from "k6";

export const options = {
  vus: 4,
  duration: "20s",
  thresholds: {
    http_req_failed: ["rate<0.01"],
    http_req_duration: ["p(95)<500"],
  },
};

export default function () {
  const response = http.get("http://127.0.0.1/projeto-korp");

  check(response, {
    "status is 200": (res) => res.status === 200,
    "response has project name": (res) => res.json("nome") === "Projeto Korp",
    "response has UTC timestamp": (res) =>
      /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/.test(res.json("horario")),
  });

  sleep(1);
}
