const functions = require("firebase-functions");
const stripe = require('stripe')(functions.config().stripe.testkey)

const calculateOrderAmount = (items) => {
    prices = [];
    catalog = [
        { 'id': '0', 'price': 2.99 },
        { 'id': '1', 'price': 3.99 },
        { 'id': '2', 'price': 4.99 },
        { 'id': '3', 'price': 5.99 },
        { 'id': '4', 'price': 6.99 },
    ];

    items.forEach(item => {
        price = catalog.find(x => x.id == item.id).price;
        prices.push(price);
    });

    return parseInt(prices.reduce((a, b) => a + b) * 100);
};

const generateResponse = function (intent) {
    // Generate a response based on the intent's status
    switch (intent.status) {
        case 'requires_action':
            // Card requires authentication
            return {
                clientSecret: intent.client_secret,
                requiresAction: true,
                status: intent.status,
            };
        case 'requires_payment_method':
            // Card was not properly authenticated, suggest a new payment method
            return {
                error: 'Your card was denied, please provide a new payment method',
            };
        case 'succeeded':
            // Payment is complete, authentication not required
            // To cancel the payment after capture you will need to issue a Refund (https://stripe.com/docs/api/refunds).
            console.log('💰 Payment received!');
            return { clientSecret: intent.client_secret, status: intent.status };
    }
    return {
        error: 'Failed',
    };
};


exports.StripePayEndpointMethodId = functions.https.onRequest(async (req, res) => {
    const {
        paymentMethodId,
        items,
        currency,
        useStripeSdk,
    } = req.body;

    const orderAmount = calculateOrderAmount(items);

    try {
        if (paymentMethodId) {
            // Create new PaymentIntent with a PaymentMethod ID from the client.
            const params = {
                amount: orderAmount,
                confirm: true,
                confirmation_method: 'manual',
                currency,
                payment_method: paymentMethodId,
                use_stripe_sdk: useStripeSdk,
            };
            const intent = await stripe.paymentIntents.create(params);
            // After create, if the PaymentIntent's status is succeeded, fulfill the order.
            console.log(`Intent: ${intent}`);
            return res.send(generateResponse(intent));
        }
        return res.sendStatus(400);
    } catch (e) {
        // Handle "hard declines" e.g. insufficient funds, expired card, etc
        // See https://stripe.com/docs/declines/codes for more.
        return res.send({ error: e.message });
    }
});

exports.StripePayEndpointIntentId = functions.https.onRequest(async (req, res) => {
    const {
        paymentIntentId,
    } = req.body;

    try {
        if (paymentIntentId) {
            // Confirm the PaymentIntent to finalize payment after handling a required action
            // on the client.
            const intent = await stripe.paymentIntents.confirm(paymentIntentId);
            // After confirm, if the PaymentIntent's status is succeeded, fulfill the order.
            return res.send(generateResponse(intent));
        } return res.sendStatus(400);
    } catch (e) {
        // Handle "hard declines" e.g. insufficient funds, expired card, etc
        // See https://stripe.com/docs/declines/codes for more.
        return res.send({ error: e.message });
    }
    
});
// const functions = require("firebase-functions");
// const admin = require("firebase-admin");
// admin.initializeApp();

// exports.sendNotification = functions.https.onCall(async (data, context) => {
//   const message = {
//     notification: {
//       title: "Notification Title",
//       body: data.message, // The message entered by the center
//     },
//     topic: "guardians", // Send notification to the "guardians" topic
//   };

//   // Send the notification
//   await admin.messaging().send(message);

//   return { success: true };
// });