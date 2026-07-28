// ============================================================
// CG Cloud Sample Data Generator (v2 - verified field names)
// Creates: Accounts (Customers), Retail Stores, Products,
//          Price Book Entries, Store Products
// Run with: sf apex run --file scripts/generate_sample_data_v2.apex --target-org CG-Cloud-Org
// ============================================================

Integer NUM_ACCOUNTS = 10;
Integer NUM_PRODUCTS = 15;

// ------------------------------------------------------------
// 1. CREATE ACCOUNTS (Customers / Retail Business Partners)
// ------------------------------------------------------------
List<Account> accountsToInsert = new List<Account>();
List<String> storeNames = new List<String>{
    'SriLakshmi Supermarket', 'MegaMart', 'GreenValley Grocers',
    'CityFresh Market', 'SunriseStores', 'BlueSky Retail',
    'FreshDaily Mart', 'GoldenGate Grocery', 'MetroExpress Store',
    'HarvestHome Market', 'QuickBuy Superstore', 'ValueMart Central',
    'PrimeChoice Retail', 'EverydayEssentials', 'TopShelf Grocers'
};

for (Integer i = 0; i < NUM_ACCOUNTS; i++) {
    String nm = (i < storeNames.size()) ? storeNames[i] : 'SampleStore ' + i;
    accountsToInsert.add(new Account(
        Name = nm,
        BillingStreet = '123 Market Street',
        BillingCity = 'Bengaluru',
        BillingState = 'Karnataka',
        BillingPostalCode = '56000' + Math.mod(i, 9),
        BillingCountry = 'India',
        Phone = '080-4000-' + (1000 + i),
        Industry = 'Retail'
    ));
}
insert accountsToInsert;
System.debug('Accounts created: ' + accountsToInsert.size());

// ------------------------------------------------------------
// 2. CREATE RETAIL STORES (linked to Accounts via Master-Detail)
// AccountId is REQUIRED (Master-Detail relationship)
// ------------------------------------------------------------
List<RetailStore> storesToInsert = new List<RetailStore>();
for (Account acc : accountsToInsert) {
    storesToInsert.add(new RetailStore(
        Name = acc.Name + ' - Store',
        AccountId = acc.Id,
        StoreType = 'Supermarket'   // adjust to match your org's picklist values
        // Optional fields you may want to set:
        // Priority = 'Medium',
        // DeliveryMethod = 'Direct Store Delivery',
        // PaymentMethod = 'Invoice'
    ));
}
insert storesToInsert;
System.debug('Retail Stores created: ' + storesToInsert.size());

// ------------------------------------------------------------
// 3. CREATE PRODUCTS (Product2)
// ------------------------------------------------------------
List<Product2> productsToInsert = new List<Product2>();
List<String> productNames = new List<String>{
    'AquaPure Mineral Water 1L', 'Coca-Cola 500ML', 'ChocoDelight 100g',
    'CrunchyOats Cereal 500g', 'GoldenButter 250g', 'FreshMilk 1L',
    'CrispyChips 150g', 'SunFresh Juice 1L', 'DailyBread Loaf',
    'PureHoney 500g', 'SpicyNoodles 80g', 'CreamyYogurt 200g',
    'RoastedNuts 250g', 'GreenTea Bags 25pk', 'InstantCoffee 100g'
};

for (Integer i = 0; i < NUM_PRODUCTS; i++) {
    String nm = (i < productNames.size()) ? productNames[i] : 'SampleProduct ' + i;
    productsToInsert.add(new Product2(
        Name = nm,
        ProductCode = 'SKU-' + (1000 + i),
        IsActive = true,
        Family = 'Consumer Goods'
    ));
}
insert productsToInsert;
System.debug('Products created: ' + productsToInsert.size());

// ------------------------------------------------------------
// 4. ADD PRODUCTS TO STANDARD PRICE BOOK
// ------------------------------------------------------------
Id standardPbId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;

List<PricebookEntry> pbEntries = new List<PricebookEntry>();
for (Integer i = 0; i < productsToInsert.size(); i++) {
    pbEntries.add(new PricebookEntry(
        Pricebook2Id = standardPbId,
        Product2Id = productsToInsert[i].Id,
        UnitPrice = 50 + (i * 10),
        IsActive = true
    ));
}
insert pbEntries;
System.debug('Price Book Entries created: ' + pbEntries.size());

// ------------------------------------------------------------
// 5. LINK PRODUCTS TO STORES (Store Product)
// Fields confirmed: ProductId, RetailStoreId, AccountId, StartDate, EndDate
// Links each store to 5 rotating products
// ------------------------------------------------------------
List<StoreProduct> storeProducts = new List<StoreProduct>();
Date today = Date.today();

for (Integer s = 0; s < storesToInsert.size(); s++) {
    RetailStore store = storesToInsert[s];
    for (Integer p = 0; p < 5; p++) {
        Integer idx = Math.mod(p + s, productsToInsert.size());
        storeProducts.add(new StoreProduct(
            RetailStoreId = store.Id,
            ProductId = productsToInsert[idx].Id,
            StartDate = today,
            EndDate = today.addYears(1)
        ));
    }
}
insert storeProducts;
System.debug('Store Products created: ' + storeProducts.size());

System.debug('=== SAMPLE DATA GENERATION COMPLETE ===');
System.debug('Accounts: ' + accountsToInsert.size());
System.debug('Retail Stores: ' + storesToInsert.size());
System.debug('Products: ' + productsToInsert.size());
System.debug('Price Book Entries: ' + pbEntries.size());
System.debug('Store Products: ' + storeProducts.size());
