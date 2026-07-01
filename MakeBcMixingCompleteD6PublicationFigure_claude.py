"""Create the publication-quality Complete D6 mixing-angle figure.

Shows four OPE orders:
  pert, pert+G2, pert+G2+G3, pert+G2+G3+G3cross(AA+AB, BB_cross=0)

The last curve shows the available cross-line G3 correction; the BB cross-line
term timed out in the numerical chunk computation and is set to zero here.
The corrected projector (1/3 removed from D6ProjectSpin1Fast) is used for AA/AB.
"""

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parent
DATA_CSV   = ROOT / "BcMixingCompleteD6ThetaData_s0_53_claude.csv"
OUTPUT_DIR  = ROOT / "output_claude" / "pdf"
PREVIEW_DIR = ROOT / "output_claude" / "png"


def style_axis(ax) -> None:
    ax.grid(True, color="#D8D8D8", linestyle=(0, (4, 4)), linewidth=0.65)
    ax.tick_params(which="both", direction="in", top=True, right=True)
    ax.minorticks_on()
    for spine in ax.spines.values():
        spine.set_linewidth(0.8)


def main() -> None:
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
            "legend.fontsize": 10,
            "pdf.fonttype": 42,
            "ps.fonttype": 42,
        }
    )

    df = pd.read_csv(DATA_CSV)
    M2              = df["M2"].to_numpy()
    theta_pert      = df["ThetaPert"].to_numpy()
    theta_pertG2    = df["ThetaPertG2"].to_numpy()
    theta_total     = df["ThetaTotal"].to_numpy()
    theta_crossline = df["ThetaPartialCrossLine"].to_numpy()

    print(f"Data source: {DATA_CSV}")
    idx8 = np.argmin(np.abs(M2 - 8.0))
    print(f"M2=8, s0=53:")
    print(f"  pert             = {theta_pert[idx8]:.6f} deg")
    print(f"  pert+G2          = {theta_pertG2[idx8]:.6f} deg")
    print(f"  pert+G2+G3       = {theta_total[idx8]:.6f} deg")
    print(f"  pert+G2+G3+G3cl  = {theta_crossline[idx8]:.6f} deg")
    print(f"  Delta(G3cross)   = {theta_crossline[idx8]-theta_total[idx8]:.6f} deg")

    line_opts = {"linewidth": 1.8, "markersize": 4.8, "markevery": 1}

    fig, ax = plt.subplots(figsize=(7.35, 3.85))

    ax.plot(M2, theta_pert, color="#5E81B5", marker="o",
            label=r"$\uptheta_{\mathrm{pert}}$", **line_opts)
    ax.plot(M2, theta_pertG2, color="#E19C24", marker="s",
            label=r"$\uptheta_{\mathrm{pert}}+\mathrm{G}_2$", **line_opts)
    ax.plot(M2, theta_total, color="#E85D3F", marker="^",
            label=r"$\uptheta_{\mathrm{pert}}+\mathrm{G}_2+\mathrm{G}_3$", **line_opts)
    ax.plot(M2, theta_crossline, color="#7B3FA0", marker="D",
            linestyle="--",
            label=r"$\uptheta_{\mathrm{pert}}+\mathrm{G}_2+\mathrm{G}_3+\mathrm{G}_3^{\mathrm{cross}}$"
                  "\n"
                  r"(AA+AB; $\Pi_{BB}^{\mathrm{cross}}=0$)",
            **line_opts)

    all_y = np.concatenate([theta_pert, theta_pertG2, theta_total, theta_crossline])
    pad = 0.08 * (all_y.max() - all_y.min())
    ax.set_xlim(7.0, 9.0)
    ax.set_xticks([7.0, 7.5, 8.0, 8.5, 9.0])
    ax.set_ylim(all_y.min() - pad, all_y.max() + pad)
    ax.set_xlabel(r"$\mathrm{M}^2\,(\mathrm{GeV}^2)$")
    ax.set_ylabel(r"$\uptheta^\circ$")
    style_axis(ax)

    ax.text(
        0.035, 0.92,
        r"$s_0=53\;\mathrm{GeV}^2$",
        transform=ax.transAxes, ha="left", va="top", fontsize=12,
    )

    ax.legend(
        loc="center left",
        bbox_to_anchor=(1.035, 0.5),
        frameon=False,
        handlelength=2.2,
        labelspacing=1.0,
        borderaxespad=0,
    )

    fig.subplots_adjust(left=0.11, right=0.66, bottom=0.19, top=0.97)

    pdf_path = OUTPUT_DIR  / "BcMixingThetaOrdersCompleteD6Publication_s0_53_claude.pdf"
    png_path = PREVIEW_DIR / "BcMixingThetaOrdersCompleteD6Publication_s0_53_claude.png"
    fig.savefig(pdf_path, bbox_inches="tight", pad_inches=0.03)
    fig.savefig(png_path, dpi=220, bbox_inches="tight", pad_inches=0.03)
    plt.close(fig)

    print(pdf_path)
    print(png_path)


if __name__ == "__main__":
    main()
