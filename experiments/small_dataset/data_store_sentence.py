'''
Inserts Data to database testdb table true_embedding_test
Shows live elapsed time while storing
'''

from google import genai
from google.genai import types
import psycopg2
import time

# ---------- Gemini ----------
client = genai.Client(api_key="AIzaSyDY5vLW-OvuiY8loqB-5Mu3hvq4ccouQxk")


sentences = [
    ("Physics", "Gravity is the force that attracts objects toward each other."),
    ("Astronomy", "Stars are massive spheres of hot plasma emitting light."),
    ("Mathematics", "Algebra studies symbols and the rules for manipulating them."),
    ("Economics", "Inflation reduces the purchasing power of money over time."),
    ("History", "Ancient civilizations developed along fertile river valleys."),
    ("Geography", "Mountains are formed through tectonic plate movements."),
    ("Politics", "Democracy allows citizens to participate in governance."),
    ("Law", "Laws regulate behavior within a society."),
    ("Sociology", "Social norms influence human behavior in groups."),
    ("Education", "Learning improves knowledge and critical thinking skills."),
    ("Engineering", "Bridges are designed to withstand structural loads."),
    ("Electronics", "Circuits control the flow of electrical current."),
    ("Networking", "Routers direct data packets across networks."),
    ("Cybersecurity", "Encryption protects data from unauthorized access."),
    ("Artificial Intelligence", "Machine learning enables systems to learn from data."),
    ("Data Science", "Data analysis reveals patterns and insights."),
    ("Statistics", "Probability measures the likelihood of events."),
    ("Robotics", "Robots can perform tasks autonomously or semi-autonomously."),
    ("Cloud Computing", "Cloud platforms provide scalable computing resources."),
    ("Operating Systems", "An operating system manages hardware and software resources."),
    ("Software Engineering", "Version control tracks changes in source code."),
    ("Web Development", "HTML structures content on web pages."),
    ("Mobile Technology", "Smartphones integrate communication and computing."),
    ("Gaming", "Game engines render graphics and simulate physics."),
    ("Design", "Good design balances aesthetics and functionality."),
    ("Art", "Paintings express ideas through visual composition."),
    ("Music", "Harmony combines notes to create pleasing sounds."),
    ("Literature", "Stories convey themes through narrative and characters."),
    ("Linguistics", "Languages evolve over time through usage."),
    ("Communication", "Effective communication conveys ideas clearly."),
    ("Marketing", "Marketing promotes products and services to consumers."),
    ("Business", "Companies aim to generate profit and growth."),
    ("Finance", "Investments grow wealth over long periods."),
    ("Accounting", "Financial statements track income and expenses."),
    ("Management", "Leadership guides teams toward shared goals."),
    ("Psychology", "Emotions influence human decision-making."),
    ("Neuroscience", "The brain processes sensory information."),
    ("Health", "Regular exercise improves physical fitness."),
    ("Nutrition", "Balanced diets support overall health."),
    ("Fitness", "Strength training builds muscle mass."),
    ("Sports", "Athletes train to improve performance."),
    ("Environment", "Climate change affects global ecosystems."),
    ("Ecology", "Ecosystems consist of interacting organisms."),
    ("Agriculture", "Crops require nutrients and water to grow."),
    ("Food Science", "Cooking alters the chemical structure of ingredients."),
    ("Transportation", "Vehicles enable movement of people and goods."),
    ("Architecture", "Buildings are designed for safety and utility."),
    ("Energy", "Renewable energy comes from natural sources."),
    ("Space Science", "Satellites orbit Earth for communication."),
    ("Pharmacology", "Medicines interact with the body to treat diseases.")
]

texts = [s[1] for s in sentences]

# ---------- Generate embeddings ----------
print("\nGenerating embeddings...")
embed_start = time.time()

response = client.models.embed_content(
    model="gemini-embedding-001",
    contents=texts,
    config=types.EmbedContentConfig(task_type="RETRIEVAL_DOCUMENT")
)

embeddings = [e.values for e in response.embeddings]

print(f"Embedding dimension: {len(embeddings[0])}")
print(f"Embeddings generated in {time.time()-embed_start:.2f} sec\n")

# ---------- Postgres ----------
conn = psycopg2.connect(
    host="localhost",
    database="testdb",
    user="postgres",
    password="7870",
    port="5432"
)

cur = conn.cursor()

print("Storing into PostgreSQL...\n")
total_start = time.time()

for i, ((source, content), embedding) in enumerate(zip(sentences, embeddings), start=1):
    row_start = time.time()

    cur.execute(
        """
        INSERT INTO true_embedding_test (content, embedding, source)
        VALUES (%s, %s, %s)
        """,
        (content, str(embedding), source)
    )

    conn.commit()

    row_time = time.time() - row_start
    total_time = time.time() - total_start

    print(f"[{i}/{len(sentences)}] inserted | row {row_time:.2f}s | total {total_time:.2f}s")

cur.close()
conn.close()

print(f"\nDone. Total insertion time: {time.time()-total_start:.2f} seconds")
