Pharmo app ordering, deliverieng, selling system's mobile version.

App has 4 role.

1. PA is pharmacy employee. Make order from selected drug supplier company.

2. S is supplier's employee (seller/saler). Can order for selected customer or pharmacy. Sharing logaction for daily selling work. Make report, see history. 

3. D is supplier's employee (driver/deliver man). Select orders from packed orders. Start and end delivery. Add additional delivery. Add payment to delivery order. See order history. Edit delivery order status when delivered, returned. And can seller's all operations.

4. R is supplier's repman. Make meeting and share location.

## Folder structure

- `lib/roles/{driver,seller,repman,van_sales}/` — role-specific screens/providers for D, S, R, and VS (the merged S+D role, see `UserRole.vanSales` in `lib/authentication/role_managemant/user_role.dart`).
- `lib/views/` — screens shared across roles (cart, product, home, profile, order_history, printer, track_map, public) plus PA's own flow (`lib/views/index.dart`, `IndexPharma`).
- Keep this split: role-specific work goes in `lib/roles/`, cross-role/shared work stays in `lib/views/`. Folder names under `lib/roles/` are lowercase to match the rest of `lib/` and to stay compatible with case-sensitive filesystems (CI, some build agents). 