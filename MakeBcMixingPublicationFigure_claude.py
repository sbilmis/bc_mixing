"""Regenerate the paper-ready momentum-space mixing-angle figure.

Uses corrected projector (1/3 removed from ProjectSpin1) data from
BcMixingThetaOrdersData_s0_53_claude.csv instead of the hardcoded buggy arrays.
"""

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parent
DATA_CSV = ROOT / "BcMixingThetaOrdersData_s0_53_claude.csv"
OUTPUT_DIR = ROOT / "output_claude" / "pdf"
PREVIEW_DIR = ROOT / "output_claude" / "png"

# Load corrected data
df = pd.read_csv(DATA_CSV)
M2             = df["M2"].to_numpy()
THETA_PERT     = df["ThetaPert"].to_numpy()
THETA_PERT_G2  = df["ThetaPertG2"].to_numpy()
THETA_PERT_G2_G3 = df["ThetaPertG2G3"].to_numpy()


def style_axis(ax) -> None:
    ax.grid(True, color="#D8D8D8", linestyle=(0, (4, 4)), linewidth=0.65)
    ax.tick_params(which="both", direction="in", top=True, right=True)
    ax.minorticks_on()
    for spine in ax.spines.values():
        spine.set_linewidth(0.8)


def plot_theta_curves(ax, broad_y_range: bool = False) -> None:
    line_options = {"linewidth": 1.8, "markersize": 4.8, "markevery": 1}
    ax.plot(
        M2,
        THETA_PERT,
        color="#5E81B5",
        marker="o",
        label=r"$\uptheta_{\mathrm{pert}}$",
        **line_options,
    )
    ax.plot(
        M2,
        THETA_PERT_G2,
        color="#E19C24",
        marker="s",
        label=r"$\uptheta_{\mathrm{pert}}+\mathrm{G}_2$",
        **line_options,
    )
    ax.plot(
        M2,
        THETA_PERT_G2_G3,
        color="#E85D3F",
        marker="^",
        label=r"$\uptheta_{\mathrm{pert}}+\mathrm{G}_2+\mathrm{G}_3$",
        **line_options,
    )
    ax.set_xlim(7.0, 9.0)
    ax.set_xticks([7.0, 7.5, 8.0, 8.5, 9.0])
    if broad_y_range:
        # Widen range to accommodate larger G2 shift with corrected projector
        y_all = np.concatenate([THETA_PERT, THETA_PERT_G2, THETA_PERT_G2_G3])
        pad = 0.05 * (y_all.max() - y_all.min())
        ax.set_ylim(y_all.min() - pad - 0.1, y_all.max() + pad + 0.1)
    else:
        y_all = np.concatenate([THETA_PERT, THETA_PERT_G2, THETA_PERT_G2_G3])
        pad = 0.05 * (y_all.max() - y_all.min())
        ax.set_ylim(y_all.min() - pad, y_all.max() + pad)
    ax.set_ylabel(r"$\uptheta^\circ$")
    style_axis(ax)
    ax.text(
        0.035,
        0.92,
        r"$s_0=53\;\mathrm{GeV}^2$",
        transform=ax.transAxes,
        ha="left",
        va="top",
        fontsize=12,
    )
    ax.legend(
        loc="center left",
        bbox_to_anchor=(1.035, 0.5),
        frameon=False,
        handlelength=2.0,
        labelspacing=1.15,
        borderaxespad=0,
    )


def save_single_panel() -> tuple[Path, Path]:
    fig, ax = plt.subplots(figsize=(7.35, 3.85))
    plot_theta_curves(ax)
    ax.set_xlabel(r"$\mathrm{M}^2\,(\mathrm{GeV}^2)$")
    fig.subplots_adjust(left=0.11, right=0.73, bottom=0.19, top=0.97)
    pdf_path = OUTPUT_DIR / "BcMixingThetaOrdersPublication_s0_53_claude.pdf"
    png_path = PREVIEW_DIR / "BcMixingThetaOrdersPublication_s0_53_claude.png"
    fig.savefig(pdf_path, bbox_inches="tight", pad_inches=0.03)
    fig.savefig(png_path, dpi=220, bbox_inches="tight", pad_inches=0.03)
    plt.close(fig)
    return pdf_path, png_path


def save_two_panel() -> tuple[Path, Path]:
    delta_g2 = THETA_PERT_G2     - THETA_PERT
    delta_g3 = THETA_PERT_G2_G3  - THETA_PERT_G2

    fig, (ax_top, ax_bottom) = plt.subplots(
        2,
        1,
        figsize=(7.35, 6.25),
        sharex=True,
        gridspec_kw={"height_ratios": [1.55, 1.0], "hspace": 0.08},
    )

    plot_theta_curves(ax_top, broad_y_range=True)
    ax_top.tick_params(labelbottom=False)
    ax_top.text(
        0.965,
        0.92,
        r"\textbf{(a)}",
        transform=ax_top.transAxes,
        ha="right",
        va="top",
        fontsize=11,
    )

    line_options = {"linewidth": 1.8, "markersize": 4.8, "markevery": 1}
    ax_bottom.axhline(0.0, color="#777777", linewidth=0.8)
    ax_bottom.plot(
        M2,
        delta_g2,
        color="#E19C24",
        marker="s",
        label=r"$\Delta\uptheta_{\mathrm{G}_2}$",
        **line_options,
    )
    ax_bottom.plot(
        M2,
        delta_g3,
        color="#E85D3F",
        marker="^",
        label=r"$\Delta\uptheta_{\mathrm{G}_3}$",
        **line_options,
    )
    ax_bottom.set_xlim(7.0, 9.0)
    # auto-range for delta panel with corrected projector
    d_all = np.concatenate([delta_g2, delta_g3])
    d_pad = max(0.005, 0.15 * (d_all.max() - d_all.min()))
    ax_bottom.set_ylim(d_all.min() - d_pad, d_all.max() + d_pad)
    ax_bottom.set_xticks([7.0, 7.5, 8.0, 8.5, 9.0])
    ax_bottom.set_xlabel(r"$\mathrm{M}^2\,(\mathrm{GeV}^2)$")
    ax_bottom.set_ylabel(r"$\Delta\uptheta^\circ$")
    style_axis(ax_bottom)
    ax_bottom.legend(
        loc="center left",
        bbox_to_anchor=(1.035, 0.5),
        frameon=False,
        handlelength=2.0,
        labelspacing=1.15,
        borderaxespad=0,
    )
    ax_bottom.text(
        0.965,
        0.90,
        r"\textbf{(b)}",
        transform=ax_bottom.transAxes,
        ha="right",
        va="top",
        fontsize=11,
    )

    fig.subplots_adjust(left=0.11, right=0.73, bottom=0.11, top=0.98)
    pdf_path = OUTPUT_DIR / "BcMixingThetaContributionsTwoPanel_s0_53_claude.pdf"
    png_path = PREVIEW_DIR / "BcMixingThetaContributionsTwoPanel_s0_53_claude.png"
    fig.savefig(pdf_path, bbox_inches="tight", pad_inches=0.03)
    fig.savefig(png_path, dpi=220, bbox_inches="tight", pad_inches=0.03)
    plt.close(fig)
    return pdf_path, png_path


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
            "legend.fontsize": 11,
            "pdf.fonttype": 42,
            "ps.fonttype": 42,
        }
    )

    print(f"Data source: {DATA_CSV}")
    print(f"M2=8, s0=53:  pert={THETA_PERT[12]:.6f}  pertG2={THETA_PERT_G2[12]:.6f}  total={THETA_PERT_G2_G3[12]:.6f}")
    print(f"Delta_G2(M2=8) = {THETA_PERT_G2[12]-THETA_PERT[12]:.4f} deg")
    print(f"Delta_G3(M2=8) = {THETA_PERT_G2_G3[12]-THETA_PERT_G2[12]:.4f} deg")

    paths = (save_single_panel(), save_two_panel())
    for pdf_path, png_path in paths:
        print(pdf_path)
        print(png_path)


if __name__ == "__main__":
    main()
