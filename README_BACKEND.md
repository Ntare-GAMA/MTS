# MTS Baker's Bakery - Backend Setup Guide

## Prerequisites

1. **Node.js** (v14 or higher) - [Download here](https://nodejs.org/)
2. **MySQL** (v8.0 or higher) - [Download here](https://dev.mysql.com/downloads/)
3. **MTN MoMo Developer Account** - [Register here](https://momodeveloper.mtn.com/)

## Installation Steps

### 1. Install Dependencies

```bash
npm install
```

### 2. Setup MySQL Database

1. Start your MySQL server
2. Run the database setup script:

```bash
mysql -u root -p < database.sql
```

Or manually:
- Open MySQL Workbench or command line
- Run the queries in `database.sql` file

### 3. Configure Environment Variables

1. Copy `.env.example` to `.env`:

```bash
copy .env.example .env
```

2. Update `.env` with your credentials:

```env
# Database
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=mts_bakery
DB_PORT=3306

# MTN MoMo API (get from https://momodeveloper.mtn.com/)
MTN_MOMO_SUBSCRIPTION_KEY=your_subscription_key
MTN_MOMO_API_USER=your_api_user_uuid
MTN_MOMO_API_KEY=your_api_key
MTN_MOMO_ENVIRONMENT=sandbox
```

### 4. MTN MoMo API Setup

1. **Register** at [MTN MoMo Developer Portal](https://momodeveloper.mtn.com/)
2. **Subscribe** to the Collections product (for receiving payments)
3. **Get Credentials**:
   - Subscription Key (Ocp-Apim-Subscription-Key)
   - Create API User and API Key
4. **Add credentials** to your `.env` file

For detailed MTN MoMo setup, see: [MTN MoMo Documentation](https://momodeveloper.mtn.com/api-documentation/)

### 5. Start the Server

Development mode (with auto-restart):
```bash
npm run dev
```

Production mode:
```bash
npm start
```

The server will start on `http://localhost:3000`

## API Endpoints

### Products
- `GET /api/products` - Get all products
- `GET /api/products/category/:category` - Get products by category
- `GET /api/products/:id` - Get single product

### Orders
- `POST /api/orders` - Create new order
- `GET /api/orders/:id` - Get order by ID
- `PATCH /api/orders/:id/status` - Update order status

### Payments (MTN MoMo)
- `POST /api/payments/request-payment` - Request payment from customer
- `GET /api/payments/status/:transactionId` - Check payment status
- `POST /api/payments/callback` - Payment callback webhook

## Testing

### Test Database Connection
```bash
node -e "require('./config/database')"
```

### Test API Health
```bash
curl http://localhost:3000/api/health
```

### Test Products Endpoint
```bash
curl http://localhost:3000/api/products
```

## MTN MoMo Testing

### Sandbox Testing Numbers

MTN provides test numbers for sandbox environment:
- Test MSISDN: `46733123454`
- Amount: Any amount in RWF

### Payment Flow

1. Customer places order
2. Frontend calls `/api/orders` to create order
3. Frontend calls `/api/payments/request-payment` with order details
4. Customer receives USSD prompt on their phone
5. Customer enters PIN to approve
6. Webhook callback updates payment status
7. Call customer to confirm delivery

## Database Schema

### Tables
- `customers` - Customer information
- `products` - Product catalog
- `orders` - Order details
- `order_items` - Items in each order
- `payment_transactions` - Payment records

## Troubleshooting

### Database Connection Issues
- Check MySQL is running: `mysql -u root -p`
- Verify credentials in `.env`
- Check database exists: `SHOW DATABASES;`

### MTN MoMo API Issues
- Verify you're using sandbox environment for testing
- Check API credentials are correct
- Review MTN MoMo logs in developer portal
- Ensure phone numbers are in correct format (without country code for Rwanda)

### Port Already in Use
Change port in `.env`:
```env
PORT=3001
```

## Production Deployment

1. Set `NODE_ENV=production` in `.env`
2. Update MTN MoMo to production environment:
   ```env
   MTN_MOMO_ENVIRONMENT=production
   MTN_MOMO_BASE_URL=https://proxy.momoapi.mtn.com
   ```
3. Use production database
4. Enable HTTPS
5. Set up proper callback URL for webhooks

## Security Notes

- Never commit `.env` file to version control
- Use strong database passwords
- Keep API keys secure
- Enable HTTPS in production
- Implement rate limiting for API endpoints
- Add authentication for admin endpoints

## Support

For issues or questions:
- MTN MoMo: support@momodeveloper.mtn.com
- Database: Check MySQL documentation
- Backend: Check server logs in console
