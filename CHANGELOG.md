# Changelog

## [0.2.2](https://github.com/matteoredz/rack-idempotency_key/compare/v0.2.1...v0.2.2) (2025-01-31)


### Miscellaneous Chores

* explicitly add rack &gt;= 2 runtime dependency ([#22](https://github.com/matteoredz/rack-idempotency_key/issues/22)) ([366bfa8](https://github.com/matteoredz/rack-idempotency_key/commit/366bfa853afe75ce6b0811c8b01246fd965dc5b2))

## [0.2.1](https://github.com/matteoredz/rack-idempotency_key/compare/v0.2.0...v0.2.1) (2025-01-31)


### Continuous Integration

* add rack 2 and 3 via appraisal gem ([#21](https://github.com/matteoredz/rack-idempotency_key/issues/21)) ([b603427](https://github.com/matteoredz/rack-idempotency_key/commit/b603427915422dabf658dcaad5a2af5199f64d44))


### Code Refactoring

* remove direct dependency on redis-rb ([#19](https://github.com/matteoredz/rack-idempotency_key/issues/19)) ([08d7a48](https://github.com/matteoredz/rack-idempotency_key/commit/08d7a488876c2029c8f8b80ce54ff1ad0086532e))

## [0.2.0](https://github.com/matteoredz/rack-idempotency_key/compare/v0.1.1...v0.2.0) (2025-01-30)


### Continuous Integration

* add code climate coverage sync ([#6](https://github.com/matteoredz/rack-idempotency_key/issues/6)) ([4196edf](https://github.com/matteoredz/rack-idempotency_key/commit/4196edf2194668084d15ca3414ab3dd3d01551d4))
* trigger lint and test before release ([#8](https://github.com/matteoredz/rack-idempotency_key/issues/8)) ([033aedd](https://github.com/matteoredz/rack-idempotency_key/commit/033aedd29ff24308ebdf6f4ea0d162374dd399af))
* update gh workflows ([#5](https://github.com/matteoredz/rack-idempotency_key/issues/5)) ([84aa493](https://github.com/matteoredz/rack-idempotency_key/commit/84aa49341cf74e057efb48e2e68b5901d9843226))


### Miscellaneous Chores

* update Rakefile to use rspec ([#7](https://github.com/matteoredz/rack-idempotency_key/issues/7)) ([eb866ee](https://github.com/matteoredz/rack-idempotency_key/commit/eb866eea6d5ba9dac599a9c3b2cd239b0471b853))


### Documentation

* add quality badges ([#18](https://github.com/matteoredz/rack-idempotency_key/issues/18)) ([f8bcc96](https://github.com/matteoredz/rack-idempotency_key/commit/f8bcc96421b6b167a578728ff0d1eeb9c5eccff3))
* add warning to readme ([#11](https://github.com/matteoredz/rack-idempotency_key/issues/11)) ([e0333c8](https://github.com/matteoredz/rack-idempotency_key/commit/e0333c813aaf2969bebad9ea72056a9d36e9489f))


### Features

* add request hashing ([#16](https://github.com/matteoredz/rack-idempotency_key/issues/16)) ([f0169fe](https://github.com/matteoredz/rack-idempotency_key/commit/f0169feb088c09c24d68c13a4f640fb41204e4e4))
* allow redis store to receive a connection pool ([#13](https://github.com/matteoredz/rack-idempotency_key/issues/13)) ([adafc66](https://github.com/matteoredz/rack-idempotency_key/commit/adafc66cee442cc7521c559f2b4fc46651f9c0f9))
* properly handle concurrent requests from Memory and Redis stores ([#15](https://github.com/matteoredz/rack-idempotency_key/issues/15)) ([d7fbbcc](https://github.com/matteoredz/rack-idempotency_key/commit/d7fbbccce3211e4ff2ce0b0d4ac0e7df4bbd5a10))


### Bug Fixes

* **docs:** document the correct default expiration time ([#17](https://github.com/matteoredz/rack-idempotency_key/issues/17)) ([ac0ea44](https://github.com/matteoredz/rack-idempotency_key/commit/ac0ea44ad5a7ecd450a2b8be11a192a19b7222cb))


### Code Refactoring

* better organise the idempotent request public interface ([#10](https://github.com/matteoredz/rack-idempotency_key/issues/10)) ([0f07fb2](https://github.com/matteoredz/rack-idempotency_key/commit/0f07fb2f55c62b0f08f2b8b96e040b494db48a6e))
* change default store duration to 5 minutes ([#14](https://github.com/matteoredz/rack-idempotency_key/issues/14)) ([6fa2537](https://github.com/matteoredz/rack-idempotency_key/commit/6fa2537cd43d32b159e82064a938d9195f42ab7b))
* remove configurable routes ([#12](https://github.com/matteoredz/rack-idempotency_key/issues/12)) ([2463b55](https://github.com/matteoredz/rack-idempotency_key/commit/2463b555188b5c4fee436ff6f96f3144a66c16fa))

## [0.1.1](https://github.com/matteoredz/rack-idempotency_key/compare/v0.1.0...v0.1.1) (2023-03-31)


### Bug Fixes

* check size of path segments against each configured route ([#3](https://github.com/matteoredz/rack-idempotency_key/issues/3)) ([248d6ca](https://github.com/matteoredz/rack-idempotency_key/commit/248d6cafbcb875781b0a3673db8561d31db464f7))

## 0.1.0 (2023-01-20)


### Miscellaneous Chores

* release as 0.1.0 ([13a2d30](https://github.com/matteoredz/rack-idempotency_key/commit/13a2d30f0ed0de82a8e94b0526c70adb6411e79e))
