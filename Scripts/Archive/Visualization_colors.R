aka3 = list(
    Histology   = c(
        Pancreatic_NEN = "BLACK",
        Colorectal_NEN = "Orange",
        Small_intestinal_NEN = "Yellow",
        Gastric_NEN = "purple",
        Liver = "Darkgreen",
        CUP = "pink"),
    Deco_type = c(alpha = "Blue",beta = "Yellow",gamma = "Orange",delta = "Purple", e13.5 = "Brown", hsc = "white"),
    NEC_NET = c(NEC= "red", NET = "blue", Unknown = "white"),
    Study = c(Groetzinger = "brown", Scarpa = "darkgreen"),
    MKI67 = c(high = "White", medium = "gray", low = "black"),
    Correlation = c(high = "Red", medium = "Yellow", low = "Green"),
    Deco_similarity = c(low = "Red", medium = "Yellow", high = "Green"),
    StromalScore = c(high = "White", medium = "gray", low = "Black"),
    Alpha_similarity = c(low = "white", high = "blue",not_sig = "gray"),
    Beta_similarity = c(low = "white", high = "darkgreen",not_sig = "gray"),
    Gamma_similarity = c(low = "white", high = "orange",not_sig = "gray"),
    Delta_similarity = c(low = "white", high = "Purple",not_sig = "gray"),
    Ductal_similarity = c(low = "white", high = "Black",not_sig = "gray"),
    Acinar_similarity = c(low = "white", high = "Brown",not_sig = "gray"),
    Progenitor_similarity = c(low = "white", high = "darkred",not_sig = "gray"),
    Differentiated_similarity= c(low = "white", high = "darkgreen",not_sig = "gray"),
    Diff_Type_Three = c(Differentiated = "darkgreen", Progenitor = "Brown", HESC = "Black"),
    HISC_similarity = c(low = "white", high = "black",not_sig = "gray"),
    HESC_similarity = c(low = "white", high = "black",not_sig = "gray"),
    Functionality = c( Unknown = "White",Functional = "green", Non_Functional="red"),
    Grading = c( G1 = "Green",G2 = "Yellow", G3 = "Red", G0 = "white"),
    Differentiation_type = c( Alpha = "blue", Beta ="green", Gamma = "Orange", Delta = "Purple", Progenitor = "Yellow", HESC = "brown", not_sig = "gray"),
    Subtype = c( alpha = "blue", beta ="green", gamma = "Orange", delta = "Purple", progenitor = "Yellow", hesc = "brown", not_significant = "gray"),
    De_differentiatedness = c(low = "red", medium = "white", high = "green"),
    Differentiatedness = c(low = "white", high = "darkgreen"),
    De_differentiation_score = c(low = "red", medium = "white", high = "green"),
    Differentiation_score = c(low = "red", medium = "white", high = "green"),
    Differentiation_Stage_Aggregated = c(
        differentiated = "darkgreen",
        stem_cell = "red",
        progenitor     = "orange",
        Not_significant= "gray"
    ),Location = c(
        Primary = "red",
        Liver_Met = "Darkgreen",
        Control = "White",
        Lymph_node_Met = "Yellow",
        Peritoneum_Met = "Black",
        Spleen_Met = "Cyan",
        Lung_Met = "Blue")
)