"""Create the publication-quality Monte Carlo histogram using corrected projector samples."""

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.lines import Line2D


ROOT = Path(__file__).resolve().parent
OUTPUT_DIR  = ROOT / "output_claude" / "pdf"
PREVIEW_DIR = ROOT / "output_claude" / "png"
PRODUCTION_SAMPLES = ROOT / "BcMixingMonteCarloSamplesPublication_claude.csv"
FALLBACK_SAMPLES   = ROOT / "BcMixingMonteCarloSamplesPublication.csv"


def normal_pdf(x: np.ndarray, mean: float, sigma: float) -> np.ndarray:
    return np.exp(-0.5 * ((x - mean) / sigma) ** 2) / (
        sigma * np.sqrt(2.0 * np.pi)
    )


def main() -> None:
    sample_file = (
        PRODUCTION_SAMPLES if PRODUCTION_SAMPLES.exists() else FALLBACK_SAMPLES
    )
    print(f"Using samples: {sample_file}")
    values = pd.read_csv(sample_file)["ThetaDeg"].dropna().to_numpy(dtype=float)
    mean  = float(np.mean(values))
    sigma = float(np.std(values, ddof=0))
    bins  = 40 if len(values) >= 500 else 15

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    PREVIEW_DIR.mkdir(parents=True, exist_ok=True)

    plt.rcParams.update(
        {
            "font.family": "serif",
            "font.serif": ["Times New Roman", "Times", "STIXGeneral"],
            "text.usetex": True,
            "text.latex.preamble": r"\usepackage{mathptmx}\usepackage{upgreek}",
            "font.size": 11,
            "axes.labelsize": 13,
            "xtick.labelsize": 11,
            "ytick.labelsize": 11,
            "legend.fontsize": 11,
            "pdf.fonttype": 42,
            "ps.fonttype": 42,
        }
    )

    fig, ax = plt.subplots(figsize=(7.2, 3.85))
    hist_color = "#5E81B5"
    fit_color  = "#C9231A"

    ax.hist(
        values,
        bins=bins,
        density=True,
        color=hist_color,
        alpha=0.82,
        edgecolor="#465A73",
        linewidth=0.45,
    )

    span = max(4.0 * sigma, 0.5 * (values.max() - values.min()))
    x = np.linspace(mean - span, mean + span, 600)
    ax.plot(x, normal_pdf(x, mean, sigma), color=fit_color, linewidth=2.0)
    ax.axvline(mean, color="#333333", linestyle=(0, (3, 3)), linewidth=1.5)

    ax.set_xlabel(r"$\uptheta^\circ$")
    ax.set_ylabel(r"\textrm{Probability density}")
    ax.tick_params(which="both", direction="in", top=True, right=True)
    ax.minorticks_on()
    for spine in ax.spines.values():
        spine.set_linewidth(0.8)

    handles = [
        Line2D([0], [0], color=fit_color, linewidth=2.0),
        Line2D([0], [0], color="#333333", linestyle=(0, (3, 3)), linewidth=1.5),
    ]
    labels = [
        r"\textrm{Gaussian fit}",
        rf"$\uptheta=({mean:.1f}\pm{sigma:.1f})^\circ$",
    ]
    ax.legend(
        handles,
        labels,
        loc="upper right",
        frameon=False,
        handlelength=2.2,
        labelspacing=0.8,
    )

    fig.subplots_adjust(left=0.12, right=0.97, bottom=0.19, top=0.97)
    pdf_path = OUTPUT_DIR / "BcMixingMonteCarloHistogramPublication_claude.pdf"
    png_path = PREVIEW_DIR / "BcMixingMonteCarloHistogramPublication_claude.png"
    fig.savefig(pdf_path, bbox_inches="tight", pad_inches=0.03)
    fig.savefig(png_path, dpi=220, bbox_inches="tight", pad_inches=0.03)
    plt.close(fig)

    print(f"Samples: {len(values)}")
    print(f"Mean:  {mean:.6f} deg")
    print(f"Sigma: {sigma:.6f} deg")
    print(pdf_path)
    print(png_path)


if __name__ == "__main__":
    main()
