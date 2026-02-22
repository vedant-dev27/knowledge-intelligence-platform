'''
Performs Search and plots the comparison bar chart
'''

from google import genai
import psycopg2
import matplotlib.pyplot as plt

# -------- Gemini ----------
client = genai.Client(api_key="AIzaSyDY5vLW-OvuiY8loqB-5Mu3hvq4ccouQxk")

query = input("Enter Query \n")
print("Searching...")
response = client.models.embed_content(
    model="gemini-embedding-001",
    contents=query
)

query_vector = response.embeddings[0].values

# -------- Postgres ----------
conn = psycopg2.connect(
    host="localhost",
    database="testdb",
    user="postgres",
    password="7870",
    port="5432"
)

cur = conn.cursor()

sql = """
SELECT id, content, source,
1 - (embedding <=> %s) AS similarity
FROM embed_from_file
ORDER BY similarity DESC;
"""

cur.execute(sql, (str(query_vector),))
rows = cur.fetchall()

print("\nTop semantic matches:\n")

labels = []
scores = []

for r in rows:
    sim = float(r[3])
    print(f"Similarity: {sim:.4f}")
    print(f"Content: {r[1]}")
    print(f"Source: {r[2]}")
    print("----")

    labels.append(r[2])   # using source as label
    scores.append(sim)

cur.close()
conn.close()

# -------- Plot graph ----------
plt.figure(figsize=(8,5))
plt.bar(labels, scores)
plt.xlabel("Document Source")
plt.ylabel("Cosine Similarity")
plt.title("Query vs Stored Documents (Semantic Similarity)")
plt.ylim(0,1)
plt.show()