# Technical Notes

### Media Types and MIME

Media types (formerly known as MIME types) represent a two-part identifier for file formats and format contents transmitted on the Internet. The [Internet Assigned Numbers Authority (IANA)](https://www.iana.org/assignments/media-types/media-types.xhtml) is the official registry for these types. They were originally defined in [RFC 2046](https://datatracker.ietf.org/doc/html/rfc2046) for use in email, but they have since been adopted by HTTP and other protocols to describe message payload content.

The `@dashkite/media-type` package strictly parses these types, separating the primary type (e.g., `text`, `application`) from the subtype (e.g., `html`, `json`), and extracting additional parameters like `charset` or `q` (quality values) for precise identification.

### Content Negotiation

[Content negotiation](https://developer.mozilla.org/en-US/docs/Web/HTTP/Content_negotiation) is a mechanism defined in HTTP that makes it possible to serve different representations of a resource at the same URI, allowing the client to specify which version fits its capabilities best.

The `Accept` class implements proactive content negotiation based on the [HTTP specification (RFC 7231)](https://httpwg.org/specs/rfc7231.html#rfc.section.5.3.2). It interprets the `q` (quality) parameters to determine the relative precedence of client preferences, enabling developers to map incoming requests to the optimal representation from their supported target formats.
