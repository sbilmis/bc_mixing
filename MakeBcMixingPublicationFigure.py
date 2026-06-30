"""Regenerate the paper-ready momentum-space mixing-angle figure.

The numerical curves are the 25-point data stored in BcMixingMomentum.nb.
For the publication version, the standard G3 and cross-line G3 bookkeeping
are presented as one final OPE curve rather than as separate legend entries.
"""

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np


ROOT = Path(__file__).resolve().parent
OUTPUT_DIR = ROOT / "output" / "pdf"
PREVIEW_DIR = ROOT / "tmp" / "pdfs"

M2 = np.array(
    [
        7.0,
        7.083333333333334,
        7.166666666666666,
        7.25,
        7.333333333333334,
        7.416666666666667,
        7.5,
        7.583333333333333,
        7.666666666666667,
        7.75,
        7.833333333333333,
        7.916666666666667,
        8.0,
        8.083333333333334,
        8.166666666666666,
        8.25,
        8.333333333333334,
        8.416666666666666,
        8.5,
        8.583333333333334,
        8.666666666666666,
        8.75,
        8.833333333333334,
        8.916666666666668,
        9.0,
    ]
)

THETA_PERT = np.array(
    [
        42.973718585936965,
        42.992115224380576,
        43.010098125068076,
        43.02767963358901,
        43.044871678333564,
        43.06168578360936,
        43.07813308263454,
        43.094224330361854,
        43.109969916095864,
        43.12537987587257,
        43.140463904576514,
        43.15523136777577,
        43.169691313259584,
        43.18385248226751,
        43.1977233204021,
        43.211311988219954,
        43.22462637149888,
        43.237674091180246,
        43.250462512988065,
        43.262998756727455,
        43.27528970526651,
        43.287342013206334,
        43.299162115245494,
        43.310756234244984,
        43.322130389001,
    ]
)

THETA_PERT_G2 = np.array(
    [
        43.00730705411297,
        43.0252068509718,
        43.04270990711317,
        43.05982778567684,
        43.076571676225775,
        43.09295240507198,
        43.10898044567712,
        43.124665929066744,
        43.140018654206905,
        43.155048098298906,
        43.16976342695604,
        43.18417350423128,
        43.19828690247128,
        43.21211191197582,
        43.2256565504466,
        43.23892857221246,
        43.251935477221274,
        43.26468451979141,
        43.277182717117846,
        43.289436857530276,
        43.301453508501815,
        43.31323902440848,
        43.324799554041064,
        43.336141047871735,
        43.34726926507843,
    ]
)

THETA_PERT_G2_G3 = np.array(
    [
        42.99811928922863,
        43.016214234380485,
        43.03390578087014,
        43.05120579178292,
        43.068125740250615,
        43.0846767207966,
        43.10086946068731,
        43.11671433123395,
        43.13222135899684,
        43.147400236852775,
        43.16226033489281,
        43.17681071112285,
        43.191060121945995,
        43.20501703240883,
        43.218689626198284,
        43.232085815379016,
        43.24521324986406,
        43.25807932661391,
        43.27069119856138,
        43.28305578326148,
        43.29517977126684,
        43.30706963423064,
        43.318731632740345,
        43.3301718238858,
        43.341396068566375,
    ]
)


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
        ax.set_ylim(42.2, 44.15)
        ax.set_yticks([42.5, 43.0, 43.5, 44.0])
    else:
        ax.set_ylim(42.95, 43.38)
        ax.set_yticks([43.0, 43.1, 43.2, 43.3])
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
    pdf_path = OUTPUT_DIR / "BcMixingThetaOrdersPublication_s0_53.pdf"
    png_path = PREVIEW_DIR / "BcMixingThetaOrdersPublication_s0_53.png"
    fig.savefig(pdf_path, bbox_inches="tight", pad_inches=0.03)
    fig.savefig(png_path, dpi=220, bbox_inches="tight", pad_inches=0.03)
    plt.close(fig)
    return pdf_path, png_path


def save_two_panel() -> tuple[Path, Path]:
    delta_g2 = THETA_PERT_G2 - THETA_PERT
    delta_g3 = THETA_PERT_G2_G3 - THETA_PERT_G2

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
    ax_bottom.set_ylim(-0.012, 0.038)
    ax_bottom.set_xticks([7.0, 7.5, 8.0, 8.5, 9.0])
    ax_bottom.set_yticks([-0.01, 0.00, 0.01, 0.02, 0.03])
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
    pdf_path = OUTPUT_DIR / "BcMixingThetaContributionsTwoPanel_s0_53.pdf"
    png_path = PREVIEW_DIR / "BcMixingThetaContributionsTwoPanel_s0_53.png"
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

    paths = (save_single_panel(), save_two_panel())
    for pdf_path, png_path in paths:
        print(pdf_path)
        print(png_path)


if __name__ == "__main__":
    main()
