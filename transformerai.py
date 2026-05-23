import random
import math

# -----------------------
# VOCAB + MEMORY
# -----------------------
tokens = {}
inv_tokens = []

def encode(word):
    if word not in tokens:
        tokens[word] = len(tokens)
        inv_tokens.append(word)
    return tokens[word]

def decode(idx):
    if idx < len(inv_tokens):
        return inv_tokens[idx]
    return "?"

# -----------------------
# EMBEDDINGS
# -----------------------
D = 8
emb = {}

def get_vec(i):
    if i not in emb:
        emb[i] = [random.uniform(-0.5, 0.5) for _ in range(D)]
    return emb[i]

# -----------------------
# MODEL PARAMETERS (tiny transformer)
# -----------------------
HEADS = 2

def init_matrix():
    return [[random.uniform(-0.2, 0.2) for _ in range(D)] for _ in range(D)]

WQ = [init_matrix() for _ in range(HEADS)]
WK = [init_matrix() for _ in range(HEADS)]
WV = [init_matrix() for _ in range(HEADS)]

WOUT = [random.uniform(-0.3, 0.3) for _ in range(D)]

# -----------------------
# VECTOR OPS
# -----------------------
def dot(a, b):
    return sum(x * y for x, y in zip(a, b))

def matvec(m, v):
    return [dot(row, v) for row in m]

def add(a, b):
    return [x + y for x, y in zip(a, b)]

def scale(v, s):
    return [x * s for x in v]

def softmax(x):
    e = [math.exp(i) for i in x]
    s = sum(e)
    return [i / s for i in e]

# -----------------------
# ATTENTION
# -----------------------
def attention(vectors, h):
    Q = [matvec(WQ[h], v) for v in vectors]
    K = [matvec(WK[h], v) for v in vectors]
    V = [matvec(WV[h], v) for v in vectors]

    outputs = []

    for i in range(len(vectors)):
        scores = []
        for j in range(len(vectors)):
            scores.append(dot(Q[i], K[j]) / math.sqrt(D))

        weights = softmax(scores)

        out = [0] * D
        for j in range(len(vectors)):
            out = add(out, scale(V[j], weights[j]))

        outputs.append(out)

    return outputs

# -----------------------
# MULTI-HEAD
# -----------------------
def multi_head(vectors):
    all_out = []

    for h in range(HEADS):
        all_out.extend(attention(vectors, h))

    final = [0] * D
    for v in all_out:
        final = add(final, v)

    return scale(final, 1 / len(all_out))

# -----------------------
# NEXT TOKEN PREDICTION
# -----------------------
def predict_next(context_vec):
    scores = []

    for i in range(len(inv_tokens)):
        v = get_vec(i)
        scores.append(dot(context_vec, v))

    probs = softmax(scores)
    return probs

# -----------------------
# GENERATE TEXT (GPT STYLE)
# -----------------------
def generate(prompt, max_len=10):
    words = prompt.split()
    ids = [encode(w) for w in words]

    for _ in range(max_len):
        vecs = [get_vec(i) for i in ids]

        context = multi_head(vecs)

        probs = predict_next(context)

        next_id = random.choices(range(len(probs)), weights=probs)[0]

        ids.append(next_id)

    return " ".join(decode(i) for i in ids)

# -----------------------
# SIMPLE TRAINING (next-word learning)
# -----------------------
def train(sentence):
    words = sentence.split()
    ids = [encode(w) for w in words]

    lr = 0.05

    for i in range(len(ids) - 1):
        context = get_vec(ids[i])
        target = get_vec(ids[i + 1])

        for j in range(D):
            context[j] += lr * target[j]

# -----------------------
# CHAT LOOP
# -----------------------
print("Mini GPT ready. Type text:")

while True:
    text = input("> ")

    if text.startswith("/gen"):
        prompt = text.replace("/gen", "").strip()
        print(generate(prompt))
        continue

    train(text)

    print(generate(text, max_len=5))