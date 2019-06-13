#### Digital Music Dataset

+ [reviews_Digital_Music_5.json.gz](snap.stanford.edu/data/amazon/productGraph/categoryFiles/reviews_Digital_Music_5.json.gz)

+ [ratings_Digital_Music.csv](snap.stanford.edu/data/amazon/productGraph/categoryFiles/ratings_Digital_Music.csv)

> Description

This dataset contains product reviews and metadata from Amazon, including 142.8 million reviews spanning May 1996 - July 2014.

This dataset includes reviews (ratings, text, helpfulness votes), product metadata (descriptions, category information, price, brand, and image features), and links (also viewed/also bought graphs).

#### Sample review:
```javascript
{ 
  "reviewerID": "A2SUAM1J3GNN3B",
  "asin": "0000013714",
  "reviewerName": "J. McDonald",
  "helpful": [2, 3],
  "reviewText": "I bought this for my husband who plays the piano. He is having a wonderful time playing these old hymns. The music is at times hard to read because we think the book was published for singing from more than playing from. Great purchase though!",
  "overall": 5.0,
  "summary": "Heavenly Highway Hymns",
  "unixReviewTime": 1252800000,
  "reviewTime": "09 13, 2009"
}

```
where

   + reviewerID - ID of the reviewer, e.g. A2SUAM1J3GNN3B
   + asin - ID of the product, e.g. 0000013714
   + reviewerName - name of the reviewer
   + helpful - helpfulness rating of the review, e.g. 2/3
   + reviewText - text of the review
   + overall - rating of the product
   + summary - summary of the review
   + unixReviewTime - time of the review (unix time)
   + reviewTime - time of the review (raw)
