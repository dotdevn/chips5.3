# Completed CHIP 5.3

- Live application: https://rottenpotatoes-dotdevn.onrender.com
- Assignment repository: https://github.com/dotdevn/chips5.3
- Render uses the existing `dotdevn/chip4.8` service with the same filtering, sorting, and session implementation. Its existing PostgreSQL connection is retained.
- Seed data is idempotent and contains the ten movies from the CHIP 5.3 template.

## Verification

Run `bundle exec rails db:prepare` and `bundle exec rails test` to check filtering, both sort orders, form IDs, session preferences, and movie CRUD without a browser.

## Submission

Upload a plain text file named `rottenpotatoes-url.txt` containing exactly:

```text
https://rottenpotatoes-dotdevn.onrender.com
```

Part 4 asks for the deployed HTTPS URL file. A source ZIP alone does not meet the deployment requirement.
