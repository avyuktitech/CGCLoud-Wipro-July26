// ============================================================
// CG Cloud Sample Data Generator (BATCH 2 - new names)
// Creates: Accounts (Customers), Retail Stores, Products,
//          Price Book Entries, Store Products
// Run with: sf apex run --file scripts/generate_sample_data_batch2.apex --target-org CG-Cloud-Org
// ============================================================

Integer NUM_ACCOUNTS = 10;
Integer NUM_PRODUCTS = 15;
String runSuffix = ' #' + String.valueOf(Datetime.now().getTime()).right(5); // extra safety, avoids dup rule even on re-run

// ------------------------------------------------------------
// 1. CREATE ACCOUNTS (Customers / Retail Business Partners)
// ------------------------------------------------------------
List<Account> accountsToInsert = new List<Account>();
List<String> storeNames = new List<String>{
    'Riverside Fresh Market', 'Oakwood Grocers', 'Silverline Superstore',
    'Coastal Pantry', 'UrbanNest Grocery', 'Maple & Main Market',
    'Northgate Provisions', 'Willow Creek Foods', 'Brightside Grocers',
    'Cedar Hill Mart', 'Lakeside Fresh Foods', 'Ironwood Retail Co',
    'Pinehurst Grocery', 'Meadowbrook Market', 'Falcon Ridge Foods'
};

for (Integer i = 0; i < NUM_ACCOUNTS; i++) {
    String nm = (i < storeNames.size()) ? storeNames[i] : 'NewSampleStore ' + i;
    accountsToInsert.add(new Account(
        Name = nm + runSuffix,
        BillingStreet = '456 Commerce Lane',
        BillingCity = 'Bengaluru',
        BillingState = 'Karnataka',
        BillingPostalCode = '56001' + Math.mod(i, 9),
        BillingCountry = 'India',
        Phone = '080-5000-' + (2000 + i),
        Industry = 'Retail'
    ));
}
insert accountsToInsert;
System.debug('Accounts created: ' + accountsToInsert.size());

// ------------------------------------------------------------
// 2. CREATE RETAIL STORES (linked to Accounts via Master-Detail)
// ------------------------------------------------------------
List<RetailStore> storesToInsert = new List<RetailStore>();
for (Account acc : accountsToInsert) {
    storesToInsert.add(new RetailStore(
        Name = acc.Name + ' - Store',
        AccountId = acc.Id,
        StoreType = 'Supermarket'   // adjust to match your org's picklist values
    ));
}
insert storesToInsert;
System.debug('Retail Stores created: ' + storesToInsert.size());

// ------------------------------------------------------------
// 3. CREATE PRODUCTS (Product2) - new names, different category
// ------------------------------------------------------------
List<Product2> productsToInsert = new List<Product2>();
List<String> productNames = new List<String>{
    'Organic Rolled Oats 500g', 'Almond Milk 1L', 'Sourdough Bread Loaf',
    'Extra Virgin Olive Oil 500ml', 'Basmati Rice 5kg', 'Peanut Butter 350g',
    'Greek Yogurt 400g', 'Whole Wheat Pasta 400g', 'Dark Chocolate Bar 100g',
    'Sparkling Water 12pk', 'Granola Bars 6pk', 'Frozen Mixed Veg 500g',
    'Cheddar Cheese Block 200g', 'Herbal Tea Assortment 20pk', 'Cold Brew Coffee 1L'
};

for (Integer i = 0; i < NUM_PRODUCTS; i++) {
    String nm = (i < productNames.size()) ? productNames[i] : 'NewSampleProduct ' + i;
    productsToInsert.add(new Product2(
        Name = nm + runSuffix,
        ProductCode = 'SKU2-' + (2000 + i) + runSuffix,
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
        UnitPrice = 75 + (i * 12),
        IsActive = true
    ));
}
insert pbEntries;
System.debug('Price Book Entries created: ' + pbEntries.size());

// ------------------------------------------------------------
// 5. LINK PRODUCTS TO STORES (Store Product)
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

System.debug('=== BATCH 2 SAMPLE DATA GENERATION COMPLETE ===');
System.debug('Accounts: ' + accountsToInsert.size());
System.debug('Retail Stores: ' + storesToInsert.size());
System.debug('Products: ' + productsToInsert.size());
System.debug('Price Book Entries: ' + pbEntries.size());
System.debug('Store Products: ' + storeProducts.size());
