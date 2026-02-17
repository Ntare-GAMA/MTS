# MTS Baker's Bakery - Full Stack Application

🥐 **Complete online ordering system with MTN Mobile Money integration**

## Features

- ✅ **Full-featured E-commerce** - Browse products, add to cart, checkout
- 💳 **MTN MoMo Integration** - Real-time payment processing with MTN Mobile Money API
- 🗄️ **MySQL Database** - Persistent data storage for orders, customers, and products
- 📱 **Mobile Responsive** - Works perfectly on all devices
- 🔔 **Real-time Updates** - Live payment status tracking
- 📞 **Customer Callback** - Payment-first, then call customer to confirm delivery

## Tech Stack

### Frontend
- HTML5, Tailwind CSS
- Vanilla JavaScript (ES6+)
- Lucide Icons

### Backend
- Node.js + Express
- MySQL Database
- MTN MoMo API Integration
- RESTful API

## Quick Start

### Prerequisites
- Node.js (v14+) - [Download](https://nodejs.org/)
- MySQL (v8.0+) - [Download](https://dev.mysql.com/downloads/)
- MTN MoMo Account - [Register](https://momodeveloper.mtn.com/)

### Installation

**Windows:**
```bash
install.bat
```

**Manual Installation:**

1. **Install dependencies:**
```bash
npm install
```

2. **Setup environment:**
```bash
copy .env.example .env
```
Then edit `.env` with your credentials.

3. **Setup database:**
```bash
mysql -u root -p < database.sql
```

4. **Start server:**
```bash
npm start
```

5. **Open browser:**
```
http://localhost:3000
```

## Configuration

### Database Setup

Edit `.env`:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=mts_bakery
```

### MTN MoMo API Setup

1. Register at [MTN MoMo Developer Portal](https://momodeveloper.mtn.com/)
2. Subscribe to **Collections** product
3. Create API User and Key
4. Add to `.env`:

```env
MTN_MOMO_SUBSCRIPTION_KEY=your_key
MTN_MOMO_API_USER=your_uuid
MTN_MOMO_API_KEY=your_api_key
MTN_MOMO_ENVIRONMENT=sandbox
```

## Project Structure

```
MTS/
├── index.html              # Frontend application
├── server.js               # Express server
├── package.json            # Dependencies
├── database.sql            # Database schema
├── .env.example            # Environment template
├── config/
│   └── database.js         # Database connection
├── routes/
│   ├── products.js         # Product endpoints
│   ├── orders.js           # Order endpoints
│   └── payments.js         # MTN MoMo payment endpoints
└── README.md               # This file
```

## API Endpoints

### Products
- `GET /api/products` - Get all products
- `GET /api/products/:id` - Get product by ID
- `GET /api/products/category/:category` - Get products by category

### Orders
- `POST /api/orders` - Create new order
- `GET /api/orders/:id` - Get order details
- `PATCH /api/orders/:id/status` - Update order status

### Payments
- `POST /api/payments/request-payment` - Request MTN MoMo payment
- `GET /api/payments/status/:transactionId` - Check payment status
- `POST /api/payments/callback` - Payment webhook

## Payment Flow

1. **Customer** fills order details and enters Mobile Money number
2. **Frontend** creates order via `/api/orders`
3. **Frontend** requests payment via `/api/payments/request-payment`
4. **MTN MoMo** sends USSD prompt to customer's phone
5. **Customer** enters PIN to approve payment
6. **Backend** polls payment status
7. **Frontend** shows success message
8. **Business** calls customer to confirm delivery

## Database Schema

### Tables
- `customers` - Customer information
- `products` - Product catalog (50 items pre-loaded)
- `orders` - Order records
- `order_items` - Order line items
- `payment_transactions` - Payment history

## Testing

### Test MTN MoMo (Sandbox)
Use test phone number: `46733123454`

### Test API
```bash
# Health check
curl http://localhost:3000/api/health

# Get products
curl http://localhost:3000/api/products
```

## Production Deployment

1. Update `.env`:
```env
NODE_ENV=production
MTN_MOMO_ENVIRONMENT=production
MTN_MOMO_BASE_URL=https://proxy.momoapi.mtn.com
```

2. Use production database
3. Enable HTTPS
4. Set proper callback URL
5. Use process manager (PM2):
```bash
npm install -g pm2
pm2 start server.js --name mts-bakery
```

## Troubleshooting

### Database Connection Failed
- Check MySQL is running
- Verify credentials in `.env`
- Ensure database `mts_bakery` exists

### MTN MoMo Errors
- Verify sandbox/production environment
- Check API credentials
- Review phone number format (without country code)
- Check MTN developer portal for API status

### CORS Errors
- Ensure backend is running on port 3000
- Check API_BASE_URL in index.html

## Support

- **MTN MoMo:** support@momodeveloper.mtn.com
- **Documentation:** [README_BACKEND.md](README_BACKEND.md)

## License

MIT License

---

Made with ❤️ in Kigali | © 2024 MTS Baker's Bakery
