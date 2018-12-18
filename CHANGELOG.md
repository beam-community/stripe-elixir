# Latest

## 2.2.2

- [Upgrade stripe-mock 0.38](https://github.com/code-corps/stripity_stripe/pull/436)
- *New Feature:* [Add delete endpoint to Invoiceitems](https://github.com/code-corps/stripity_stripe/pull/434)
- [Ensure tests wait until stripe_mock started](https://github.com/code-corps/stripity_stripe/pull/427)
- [Upgraded erlexec for OTP 21 support](https://github.com/code-corps/stripity_stripe/pull/426)
- [Added missing invoice attributes](https://github.com/code-corps/stripity_stripe/pull/425)
- [Enabled Dialyxir in CI](https://github.com/code-corps/stripity_stripe/pull/424)

## 2.2.1

- [Fix: date_query type had fields incorrectly marked as mandatory](https://github.com/code-corps/stripity_stripe/pull/421)
- [Added customer field to Source entity](https://github.com/code-corps/stripity_stripe/pull/420)
- [Added deleted property to resources that can be deleted](https://github.com/code-corps/stripity_stripe/pull/419)
- [Added some missing attributes to update endpoints for SKU, Charge, TransferReversal, Transfer](https://github.com/code-corps/stripity_stripe/pull/418)
- [Added API version compatibility table to README.md](https://github.com/code-corps/stripity_stripe/pull/416)
- [Bumped supported API version to 2018-08-23](https://github.com/code-corps/stripity_stripe/pull/415)
- [Updated stripe-mock dependency to 0.30.0](https://github.com/code-corps/stripity_stripe/pull/414)
- [Fixed formatting in README.md](https://github.com/code-corps/stripity_stripe/pull/412)

## 2.2.0

- [Add missing `tax_info` attributes to `customer`](https://github.com/code-corps/stripity_stripe/pull/410)
- [Ease up on hackney dependency](https://github.com/code-corps/stripity_stripe/pull/407)
- *New Feature:* [Add Recipient endpoint](https://github.com/code-corps/stripity_stripe/pull/405)
- [Expand test matrix with Elixir 1.7](https://github.com/code-corps/stripity_stripe/pull/404)
- [Convert discount responses to a struct](https://github.com/code-corps/stripity_stripe/pull/403)
- [Add `name` to `Stripe.Coupon`](https://github.com/code-corps/stripity_stripe/pull/402)
- [Add `unit_label` attribute to `Stripe.Product`](https://github.com/code-corps/stripity_stripe/pull/401)
- [Add params to `Stripe.Subscription` and `Stripe.Invoice` endpoints](https://github.com/code-corps/stripity_stripe/pull/400)
- [Add `active` attribute to `Stripe.Plan`](https://github.com/code-corps/stripity_stripe/pull/399)
- [Add `source_url` to `mix.exs`](https://github.com/code-corps/stripity_stripe/pull/398)
- [Improved formatting (using `mix format` in some files](https://github.com/code-corps/stripity_stripe/pull/397)
- [Improved webhook documentation](https://github.com/code-corps/stripity_stripe/pull/395)

## 2.1.0

- *New Feature:* [Add support for object expansion - #393](https://github.com/code-corps/stripity_stripe/pull/393)
  - credits to [@swelham](https://github.com/swelham
  - see instructions in README.md
- Replace `user_id` in event with `account` field, as per updated stripe documentation - [#391](https://github.com/code-corps/stripity_stripe/pull/391)
  - credits to [@erikreedstrom](https://github.com/erikreedstrom)
- Update officiall supported API version to 2018-05-21 - [#390]((https://github.com/code-corps/stripity_stripe/pull/390)
  - credits to [@snewcomer](https://github.com/snewcomer)

## 2.0.1

- add some missing fields to `%Stripe.Plan{}` - [#380](https://github.com/code-corps/stripity_stripe/pull/380)
- added supported API version to readme - [#384](https://github.com/code-corps/stripity_stripe/pull/384)
- corrected usage info in readme - [#384](https://github.com/code-corps/stripity_stripe/pull/384)
- added `:customer` field to `%Stripe.Card{}` - [#382](https://github.com/code-corps/stripity_stripe/pull/382)
- made `:source` field required in `Stripe.Card.create` - [#382](https://github.com/code-corps/stripity_stripe/pull/382)
- added support for optional `params: %{optional(:at_period_end) => boolean}` to `Stripe.Subscription.delete/2` - [#386](https://github.com/code-corps/stripity_stripe/pull/386)

## 2.0.0

- official full release after -alpha and -beta releases
- Readme updates related to releasing 2.0 - [#377](https://github.com/code-corps/stripity_stripe/pull/377)
- See the [latest documentation](https://hexdocs.pm/stripity_stripe/api-reference.html) to track what's supported

This is a huge release and we are likely to have missed bugs. Feel free to provide feedback, create issues and contribute with pull requests.

# 1.x.x

## 1.6.2 (2018-06-05)

- Readme updates related to releasing 2.0 - [#372], [#373], [#375]

## 1.6.1 (2018-04-03)

- We now return {:error, data} on request errors, instead of just raising errors - [#343](https://github.com/code-corps/stripity_stripe/pull/343)

## 1.6.0 (2017-07-06)

- Added support to update invoices (`&Stripe.Invoices.change/2`, `&Stripe.Invoices.change/3`) - [#241](https://github.com/code-corps/stripity_stripe/pull/241)
  - credit to https://github.com/TakteS

## 1.5.0 (2017-07-04)

- Added basic webhook support - [#244](https://github.com/code-corps/stripity_stripe/pull/244)

## 1.0.0 to 1.4.0

- Added support to generate connect button URLs - [#231](https://github.com/code-corps/stripity_stripe/pull/231)
- Remaining changes have not been tracked, too many to list.

## 1.0.0 (2015-12-22)

- Bumped version to 1.0.0 as it has become quite feature full and it has a slight breakage factor.
- Stripe Connect standalone account support. All modules were refactored to allow api key to flow thru
- Refactored all subscriptions/invoices to their own modules. Expect a few rough edges there.
- Improved the README
