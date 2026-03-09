import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go

# --- Constants ---
LF = 334000    # Latent Heat of Fusion (J/kg)
CI = 2108      # Specific Heat of Ice (J/kg*C)
CW = 4186      # Specific Heat of Water (J/kg*C)

st.set_page_config(page_title="Pro Ice Melt Lab", layout="wide")

st.title("❄️ Professional Ice Melting & Power Analysis")
st.markdown("Calculate the thermal energy and power required to phase-shift ice into water.")

# --- Sidebar Inputs ---
with st.sidebar:
    st.header("🧊 Material Parameters")
    mass = st.number_input("Total Mass of Ice (kg):", value=450000.0, min_value=0.0, step=1000.0)
    temp_initial = st.slider("Initial Ice Temp (°C):", value=-10, min_value=-50, max_value=0)
    temp_final = st.slider("Final Water Temp (°C):", value=0, min_value=0, max_value=100)
    
    st.header("⚙️ System Parameters")
    hours = st.number_input("Time Target (Hours):", value=2.0, min_value=0.01)
    efficiency = st.slider("System Efficiency (%):", value=85, min_value=1, max_value=100)
    
    st.divider()
    st.info("The efficiency factor accounts for thermal losses to the environment.")

# --- Calculations ---
seconds = hours * 3600
# 1. Energy to warm ice to 0°C
q_warm_ice = mass * CI * abs(temp_initial)
# 2. Energy to melt ice (Latent Heat)
q_melt = mass * LF
# 3. Energy to warm water to final temp
q_warm_water = mass * CW * temp_final

q_total_joules = q_warm_ice + q_melt + q_warm_water
p_theoretical_watts = q_total_joules / seconds
p_actual_watts = p_theoretical_watts / (efficiency / 100)

# --- UI Layout: Metrics ---
m1, m2, m3 = st.columns(3)
m1.metric("Total Energy Required", f"{q_total_joules/1e9:,.2f} GJ")
m2.metric("Required Power (Actual)", f"{p_actual_watts/1e6:,.2f} MW")
m3.metric("Energy Density", f"{(q_total_joules/mass)/1e3:,.1f} kJ/kg")

st.divider()

# --- Visualizations ---
col_left, col_right = st.columns([1, 1])

with col_left:
    st.subheader("Energy Component Breakdown")
    # Pie Chart for Energy Distribution
    energy_data = {
        "Phase": ["Warming Ice", "Latent Heat (Melting)", "Warming Water"],
        "Energy (GJ)": [q_warm_ice/1e9, q_melt/1e9, q_warm_water/1e9]
    }
    fig_pie = px.pie(energy_data, values='Energy (GJ)', names='Phase', 
                     color_discrete_sequence=px.colors.sequential.ice)
    st.plotly_chart(fig_pie, use_container_width=True)

with col_right:
    st.subheader("Power vs. Time Sensitivity")
    # Generate a range of hours to show the curve
    time_range = np.linspace(0.5, 10, 20)
    power_range = (q_total_joules / (time_range * 3600)) / (efficiency / 100) / 1e6
    
    fig_line = px.line(x=time_range, y=power_range, 
                       labels={'x': 'Time (Hours)', 'y': 'Required Power (MW)'},
                       title="Power Demand based on Time Deadline")
    fig_line.add_vline(x=hours, line_dash="dash", line_color="red", annotation_text="Current Target")
    st.plotly_chart(fig_line, use_container_width=True)

# --- Data Table & Export ---
st.subheader("Detailed Results Table")

results_df = pd.DataFrame({
    "Parameter": ["Mass", "Initial Temp", "Final Temp", "Time (s)", "Total Energy (GJ)", "Actual Power (MW)"],
    "Value": [mass, temp_initial, temp_final, seconds, q_total_joules/1e9, p_actual_watts/1e6],
    "Unit": ["kg", "°C", "°C", "seconds", "GJ", "MW"]
})

st.dataframe(results_df, use_container_width=True)

# Export Feature
csv = results_df.to_csv(index=False).encode('utf-8')
st.download_button(
    label="💾 Download Results as CSV",
    data=csv,
    file_name='ice_melt_analysis.csv',
    mime='text/csv',
)